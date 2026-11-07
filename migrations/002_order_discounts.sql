-- amountPaid (сумма со скидкой) из внешнего API — хранится рядом с amount_kop,
-- чтобы считать gross/net/discount без пересчёта по discountPercent.
ALTER TABLE orders ADD COLUMN amount_paid_kop BIGINT;
-- Заказы, созданные до миграции, считаем без скидки (как и приложение для amountPaid = null).
-- NULL, а не 0-по-умолчанию: 0 — легитимное значение amount_paid_kop (бесплатный заказ),
-- и не должно быть неотличимо от "ещё не забэкафиллено".
UPDATE orders SET amount_paid_kop = amount_kop WHERE amount_paid_kop IS NULL;
ALTER TABLE orders ALTER COLUMN amount_paid_kop SET NOT NULL;
