-- amountPaid (сумма со скидкой) из внешнего API — хранится рядом с amount_kop,
-- чтобы считать gross/net/discount без пересчёта по discountPercent.
ALTER TABLE orders ADD COLUMN amount_paid_kop BIGINT NOT NULL DEFAULT 0;
-- Заказы, созданные до миграции, считаем без скидки (как и приложение для amountPaid = null).
UPDATE orders SET amount_paid_kop = amount_kop WHERE amount_paid_kop = 0;
ALTER TABLE orders ALTER COLUMN amount_paid_kop DROP DEFAULT;
