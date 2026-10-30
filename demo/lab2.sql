-- 1. Какие блюда готовит ресторан "Теремок"?
-- expect: rows
SELECT d.name AS dish_name, d.price
FROM dishes d
JOIN restaurants r ON r.id = d.restaurant_id
WHERE r.name = 'Теремок';

-- 2. Какие блюда и из какого ресторана заказал клиент "ivanov@mail.ru"?
-- expect: rows
SELECT d.name AS dish_name, r.name AS restaurant_name, oi.quantity
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN dishes d ON d.id = oi.dish_id
JOIN restaurants r ON r.id = d.restaurant_id
WHERE o.customer_email = 'ivanov@mail.ru';

-- 3. Какие заказы (email клиента) были доставлены курьером "Иванов Иван"?
-- expect: rows
SELECT o.customer_email
FROM orders o
JOIN couriers c ON c.id = o.courier_id
WHERE c.full_name = 'Иванов Иван' AND o.status = 'доставлен';

-- 4. Сколько всего блюд в меню каждого ресторана?
-- expect: rows
SELECT r.name AS restaurant_name, COUNT(d.id) AS dish_count
FROM restaurants r
JOIN dishes d ON d.restaurant_id = r.id
GROUP BY r.name;

-- 5. Какие рестораны имеют в меню больше 3 блюд?
-- expect: rows
SELECT r.name AS restaurant_name, COUNT(d.id) AS dish_count
FROM restaurants r
JOIN dishes d ON d.restaurant_id = r.id
GROUP BY r.name
HAVING COUNT(d.id) > 3;

-- 6. Какие курьеры ещё не доставили ни одного заказа?
-- expect: rows
SELECT c.full_name, c.courier_number
FROM couriers c
LEFT JOIN orders o ON c.id = o.courier_id
WHERE o.id IS NULL;

-- 7. Какие клиенты (email) заказывали блюда категории "суп"?
-- expect: rows
SELECT DISTINCT customer_email
FROM orders
WHERE id IN (
    SELECT oi.order_id 
    FROM order_items oi 
    JOIN dishes d ON d.id = oi.dish_id 
    WHERE d.category = 'суп'
);

-- 8. Какие рестораны не получили ни одного заказа?
-- expect: rows
SELECT r.name
FROM restaurants r
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.restaurant_id = r.id
);

-- 9. Какие 5 самых дорогих блюд в базе (название и цена)?
-- expect: rows 5
SELECT name, price
FROM dishes
ORDER BY price DESC
LIMIT 5;

-- 10. Добавить нового курьера с номером "K-999" и проверить, что он появился
-- expect: value 1
BEGIN;
SELECT count(*) FROM couriers WHERE courier_number = 'K-999';
INSERT INTO couriers (courier_number, full_name, transport_type, district, status) 
VALUES ('K-999', 'Новый Курьер', 'пеший', 'Тверской', 'свободен');
SELECT count(*) FROM couriers WHERE courier_number = 'K-999';
ROLLBACK;

-- 11. Перевести конкретный заказ (id=1) в статус "доставлен" и проверить
-- expect: value 1
BEGIN;
SELECT count(*) FROM orders WHERE id = 1 AND status = 'доставлен';
UPDATE orders SET status = 'доставлен' WHERE id = 1;
SELECT count(*) FROM orders WHERE id = 1 AND status = 'доставлен';
ROLLBACK;

-- 12. Удалить все заказы со статусом "отменён" и убедиться, что их не осталось
-- expect: value 0
BEGIN;
SELECT count(*) FROM orders WHERE status = 'отменён';
DELETE FROM orders WHERE status = 'отменён';
SELECT count(*) FROM orders WHERE status = 'отменён';
ROLLBACK;

-- 13. Топ-3 самых дорогих блюд в каждой категории
-- expect: rows
WITH ranked_dishes AS (
    SELECT 
        name, 
        category, 
        price,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) as rn
    FROM dishes
)
SELECT name, category, price
FROM ranked_dishes
WHERE rn <= 3;

-- 14. Накопительная сумма заказов по датам
-- expect: rows
WITH daily_totals AS (
    SELECT 
        date(o.created_at) AS order_date,
        SUM(oi.quantity * oi.price_at_order) AS day_total
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    GROUP BY date(o.created_at)
)
SELECT 
    order_date, 
    day_total,
    SUM(day_total) OVER (ORDER BY order_date) AS running_total
FROM daily_totals;

-- 15. Помесячная динамика заказов с процентом изменения
-- expect: rows
WITH monthly_stats AS (
    SELECT 
        date_trunc('month', created_at) AS month,
        COUNT(*) AS monthly_orders
    FROM orders
    GROUP BY date_trunc('month', created_at)
)
SELECT 
    month,
    monthly_orders,
    LAG(monthly_orders) OVER (ORDER BY month) AS prev_month_orders,
    ROUND(
        (monthly_orders - LAG(monthly_orders) OVER (ORDER BY month))::numeric 
        / NULLIF(LAG(monthly_orders) OVER (ORDER BY month), 0) * 100, 
        2
    ) AS percent_change
FROM monthly_stats
ORDER BY month;

-- 16. Календарь на 7 дней: сколько заказов было в каждый день
-- expect: rows
WITH RECURSIVE date_calendar AS (
    SELECT CURRENT_DATE AS order_date
    UNION ALL
    SELECT (order_date + 1)::date
    FROM date_calendar
    WHERE order_date < CURRENT_DATE + 6
)
SELECT 
    dc.order_date,
    COUNT(o.id) AS orders_count
FROM date_calendar dc
LEFT JOIN orders o ON date(o.created_at) = dc.order_date
GROUP BY dc.order_date
ORDER BY dc.order_date;