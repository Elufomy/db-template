-- 1. представление(карточка)
CREATE OR REPLACE VIEW order_cards AS
SELECT 
    o.id AS order_id,
    o.customer_email,
    r.name AS restaurant_name,
    c.full_name AS courier_name,
    o.address,
    o.status,
    o.created_at
FROM orders o
LEFT JOIN restaurants r ON r.id = o.restaurant_id
LEFT JOIN couriers c ON c.id = o.courier_id;

-- 2. представление(выручка)
CREATE OR REPLACE VIEW restaurant_revenue AS
SELECT 
    r.name AS restaurant_name,
    COUNT(DISTINCT o.id) AS total_orders,
    COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS total_revenue
FROM restaurants r
LEFT JOIN orders o ON o.restaurant_id = r.id
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY r.name;

-- мат представление(выручка)
CREATE MATERIALIZED VIEW restaurant_revenue_materialized AS
SELECT 
    r.name AS restaurant_name,
    COUNT(DISTINCT o.id) AS total_orders,
    COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS total_revenue
FROM restaurants r
LEFT JOIN orders o ON o.restaurant_id = r.id
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY r.name;