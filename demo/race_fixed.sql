-- [setup] тестовые заказы
DELETE FROM orders WHERE customer_email LIKE 'race%';

INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('race1@mail.ru', 1, 1, 'адрес', 'готовится');

INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('race2@mail.ru', 1, 1, 'адрес', 'готовится');

-- [A]
BEGIN;
SELECT * FROM couriers WHERE id = 1 FOR UPDATE;

INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('race_A@mail.ru', 1, 1, 'адрес', 'готовится');

-- [B]
BEGIN;

-- expect: blocked
SELECT * FROM couriers WHERE id = 1 FOR UPDATE;

-- [A]
COMMIT;

-- [B]
-- expect: error raise
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('race_B@mail.ru', 1, 1, 'адрес', 'готовится');

ROLLBACK;

-- [check]
-- expect: true
SELECT count(*) <= 3 FROM orders
WHERE courier_id = 1
  AND status IN ('готовится', 'в пути');

-- [cleanup]
DELETE FROM orders WHERE customer_email LIKE 'race%';