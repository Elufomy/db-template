-- 3. функция(стоимость возвращает ч)
CREATE OR REPLACE FUNCTION get_order_total(p_order_id integer) 
RETURNS numeric AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(quantity * price_at_order), 0)
        FROM order_items
        WHERE order_id = p_order_id
    );
END;
$$ LANGUAGE plpgsql;

-- 4. функция(список свободных курьеров возвращает т)
CREATE OR REPLACE FUNCTION get_free_couriers()
RETURNS TABLE(courier_id integer, courier_name text, transport text) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.full_name, c.transport_type
    FROM couriers c
    WHERE c.status = 'свободен';
END;
$$ LANGUAGE plpgsql;

-- 5. бизнес-операция назначает курьера
CREATE OR REPLACE PROCEDURE assign_courier(p_order_id integer, p_courier_id integer)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE orders 
    SET courier_id = p_courier_id, status = 'готовится' 
    WHERE id = p_order_id;
    
    UPDATE couriers 
    SET status = 'занят' 
    WHERE id = p_courier_id;
END;
$$;

-- функция поиск заказа с фильтром(возвращает т)
CREATE OR REPLACE FUNCTION find_orders(
    p_status text DEFAULT NULL,
    p_restaurant text DEFAULT NULL
)
RETURNS TABLE(order_id integer, customer_email text, restaurant_name text, status text) AS $$
BEGIN
    RETURN QUERY
    SELECT o.id, o.customer_email, r.name, o.status
    FROM orders o
    JOIN restaurants r ON r.id = o.restaurant_id
    WHERE (p_status IS NULL OR o.status = p_status)
      AND (p_restaurant IS NULL OR r.name = p_restaurant);
END;
$$ LANGUAGE plpgsql;