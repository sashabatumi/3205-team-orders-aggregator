-- Внешний API начал отдавать amountPaid (сумма со скидкой). Храним её рядом с amount_kop,
-- чтобы считать gross/net/discount без пересчёта по discountPercent.
ALTER TABLE orders ADD COLUMN amount_paid_kop BIGINT NOT NULL DEFAULT 0;
-- Для уже существующих заказов amountPaid ещё не был известен — считаем их без скидки,
-- как и в приложении (см. OrdersService.normalize), иначе старые заказы задним числом
-- получат net = 0 / discount = gross в daily-totals.
UPDATE orders SET amount_paid_kop = amount_kop WHERE amount_paid_kop = 0;
ALTER TABLE orders ALTER COLUMN amount_paid_kop DROP DEFAULT;
