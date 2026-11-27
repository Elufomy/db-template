ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_sees_own ON orders;
CREATE POLICY user_sees_own ON orders
    FOR SELECT
    USING (customer_email = current_user);

-- Обрати внимание: мы НЕ даем app_reader доступ к orders напрямую!
-- Права на таблицу (для RLS-теста) дадим только внутри demo/rls.sql