-- [setup] тест заказы
ALTER TABLE orders DISABLE TRIGGER trg_check_courier_limit;
DELETE FROM orders WHERE customer_email LIKE 'race%';
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('race1@mail.ru', 1, 1, 'адрес', 'готовится');
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('race2@mail.ru', 1, 1, 'адрес', 'готовится');

-- [A]
BEGIN;
SELECT count(*) FROM orders WHERE courier_id = 1 AND status IN ('готовится', 'в пути');
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('race_A@mail.ru', 1, 1, 'адрес', 'готовится');

-- [B]
BEGIN;
SELECT count(*) FROM orders WHERE courier_id = 1 AND status IN ('готовится', 'в пути');
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('race_B@mail.ru', 1, 1, 'адрес', 'готовится');

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] проверка правила
-- expect: false
SELECT count(*) <= 3 FROM orders WHERE courier_id = 1 AND status IN ('готовится', 'в пути');

-- [cleanup]
DELETE FROM orders WHERE customer_email LIKE 'race%';
ALTER TABLE orders ENABLE TRIGGER trg_check_courier_limit;