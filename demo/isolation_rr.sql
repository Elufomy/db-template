-- [setup] тест строка
DROP TABLE IF EXISTS isolation_test;
CREATE TABLE isolation_test (id int PRIMARY KEY, val int);
INSERT INTO isolation_test VALUES (1, 100);

-- [A] 1 чтение
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- expect: value 100
SELECT val FROM isolation_test WHERE id = 1;

-- [B] меняет знач и коммит
BEGIN;
UPDATE isolation_test SET val = 200 WHERE id = 1;
COMMIT;

-- [A] 2 чтение в той же транкзации
-- expect: value 100
SELECT val FROM isolation_test WHERE id = 1;
COMMIT;

-- [cleanup]
DROP TABLE isolation_test;