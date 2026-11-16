ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- триггер у курьера не более 3
CREATE OR REPLACE FUNCTION check_courier_orders_limit()
RETURNS trigger AS $$
DECLARE
    active_count integer;
BEGIN
    IF NEW.courier_id IS NOT NULL THEN
        SELECT COUNT(*) INTO active_count
        FROM orders
        WHERE courier_id = NEW.courier_id 
          AND status IN ('готовится', 'в пути')
          AND id != NEW.id;

        IF active_count >= 3 THEN
            RAISE EXCEPTION 'Ошибка: У курьера уже 3 активных заказа!';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_courier_limit ON orders;
CREATE TRIGGER trg_check_courier_limit
    BEFORE INSERT OR UPDATE OF courier_id, status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION check_courier_orders_limit();

-- 7. тригер обновление
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_updated_at ON orders;
CREATE TRIGGER trg_update_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- 1. таблица история
CREATE TABLE IF NOT EXISTS orders_history (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id integer,
    operation text,
    old_row jsonb,
    new_row jsonb,
    changed_by text,
    changed_at timestamptz DEFAULT clock_timestamp()
);

-- 2. тригер история
CREATE OR REPLACE FUNCTION log_orders_history()
RETURNS trigger AS $$
BEGIN
    INSERT INTO orders_history (order_id, operation, old_row, new_row, changed_by)
    VALUES (
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        to_jsonb(OLD),
        to_jsonb(NEW),
        session_user
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- тригер на таблицу заказов
DROP TRIGGER IF EXISTS trg_orders_history ON orders;
CREATE TRIGGER trg_orders_history
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION log_orders_history();

-- функция состояния на дату
CREATE OR REPLACE FUNCTION get_order_state_at(p_order_id integer, p_at timestamptz)
RETURNS jsonb AS $$
DECLARE
    result jsonb;
BEGIN
    SELECT new_row INTO result
    FROM orders_history
    WHERE order_id = p_order_id
      AND changed_at <= p_at
    ORDER BY changed_at DESC
    LIMIT 1;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;