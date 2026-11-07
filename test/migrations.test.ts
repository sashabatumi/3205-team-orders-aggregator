import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";
import { createDb } from "../src/db.js";

const TEST_DATABASE_URL = process.env.TEST_DATABASE_URL ?? "postgres://postgres:postgres@localhost:5432/orders_test";

describe("миграция 002_order_discounts.sql", () => {
  it("бэкафиллит amount_paid_kop = amount_kop для заказов, созданных до миграции", async () => {
    const db = createDb(TEST_DATABASE_URL);
    const client = await db.connect();
    try {
      await client.query("BEGIN");
      // Таблица в состоянии "до миграции 002" (как после 001_init.sql) — без amount_paid_kop.
      await client.query(`
        CREATE TEMP TABLE legacy_orders (
          id          TEXT PRIMARY KEY,
          customer_id TEXT        NOT NULL,
          amount_kop  BIGINT      NOT NULL,
          status      TEXT        NOT NULL,
          created_at  TIMESTAMPTZ NOT NULL,
          updated_at  TIMESTAMPTZ NOT NULL
        ) ON COMMIT DROP
      `);
      await client.query(
        `INSERT INTO legacy_orders (id, customer_id, amount_kop, status, created_at, updated_at)
         VALUES ('o_legacy', 'c_1', 250000, 'paid', now(), now())`,
      );

      const migrationSql = await readFile(new URL("../migrations/002_order_discounts.sql", import.meta.url), "utf8");
      // Применяем ровно ту же миграцию к копии старой таблицы, чтобы проверить её на существующих данных.
      await client.query(migrationSql.replaceAll(/\borders\b/g, "legacy_orders"));

      const { rows } = await client.query<{ amount_kop: string; amount_paid_kop: string }>(
        `SELECT amount_kop, amount_paid_kop FROM legacy_orders WHERE id = 'o_legacy'`,
      );
      expect(Number(rows[0].amount_paid_kop)).toBe(Number(rows[0].amount_kop));
    } finally {
      await client.query("ROLLBACK");
      client.release();
      await db.end();
    }
  });
});
