-- 1. Количество заказов до транзакции
-- expect: rows 1
SELECT count(*) FROM orders;

-- 2. Ошибка в середине транзакции
-- expect: error 23503
BEGIN;

INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('lab4_ok@mail.ru', 1, 1, 'ул. Тестовая', 'новый');

INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('test@mail.ru', 1, 9999, 'ул. Тестовая', 'новый');

COMMIT;

-- 3. Количество заказов после отката
-- expect: same 1
SELECT count(*) FROM orders;