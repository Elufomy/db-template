-- [setup] страка проверки
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status)
VALUES ('test_rls@mail.ru', 1, 1, 'адрес', 'новый');

-- тест роль
DROP ROLE IF EXISTS rls_tester;
CREATE ROLE rls_tester LOGIN;
GRANT SELECT ON orders TO rls_tester;

-- [A] rls_tester 0 строк
SET ROLE rls_tester;
-- expect: value 0
SELECT count(*) FROM orders;
RESET ROLE;

-- [B] суперпользователь видит всё
-- expect: true
SELECT count(*) > 0 FROM orders;

-- [cleanup] - права и - доступ
REVOKE ALL ON orders FROM rls_tester;
DROP ROLE IF EXISTS rls_tester;
DELETE FROM orders WHERE customer_email = 'test_rls@mail.ru';