-- проверка карточкамзаказа
-- expect: rows
SELECT * FROM order_cards LIMIT 2;

-- проверка стоимость заказа
-- expect: rows
SELECT get_order_total(1) > 0 AS is_positive;

-- проверка бизнес операции
-- expect: ok
CALL assign_courier(1, 2);

-- проверка обновления
-- expect: rows
SELECT id, courier_id, status, updated_at FROM orders WHERE id = 1;

BEGIN;

-- заказ1
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('test1@mail.ru', 1, 1, 'ул. Тестовая 1', 'в пути');
-- заказ 2
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('test2@mail.ru', 1, 1, 'ул. Тестовая 2', 'готовится');
-- заказ 3
INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status) 
VALUES ('test3@mail.ru', 1, 1, 'ул. Тестовая 3', 'в пути');

-- проверка что количество заказов = 3
-- expect: value 3
SELECT count(*) FROM orders 
WHERE courier_id = 1 AND status IN ('готовится', 'в пути');

-- проверка нарушения
-- expect: error "У курьера уже 3 активных заказа!"
UPDATE orders SET courier_id = 1, status = 'в пути' WHERE id = 5;

ROLLBACK;

-- мат представление
-- expect: rows
SELECT * FROM restaurant_revenue_materialized LIMIT 2;
REFRESH MATERIALIZED VIEW restaurant_revenue_materialized;

-- функция с фильтрами
-- expect: rows
SELECT * FROM find_orders(p_status => 'доставлен');

-- журнал изменения
BEGIN;
INSERT INTO orders (customer_email, restaurant_id, address, status) 
VALUES ('history@mail.ru', 1, 'ул. История 1', 'новый');
UPDATE orders SET status = 'доставлен' WHERE customer_email = 'history@mail.ru';

-- expect: rows
SELECT operation, changed_by FROM orders_history ORDER BY id DESC LIMIT 2;
ROLLBACK;

-- состояние на дату
-- expect: value false
SELECT (get_order_state_at(1, now()) IS NULL) AS is_empty;