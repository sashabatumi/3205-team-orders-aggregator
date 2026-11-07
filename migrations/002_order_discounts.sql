-- Внешний API начал отдавать amountPaid (сумма со скидкой). Храним её рядом с amount_kop,
-- чтобы считать gross/net/discount без пересчёта по discountPercent.
ALTER TABLE orders ADD COLUMN amount_paid_kop BIGINT NOT NULL DEFAULT 0;
ALTER TABLE orders ALTER COLUMN amount_paid_kop DROP DEFAULT;
