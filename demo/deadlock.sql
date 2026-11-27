-- [setup] Две строки для блокировки
DROP TABLE IF EXISTS deadlock_test;
CREATE TABLE deadlock_test (id int PRIMARY KEY, val int);
INSERT INTO deadlock_test VALUES (1, 10), (2, 20);

-- [A] блок стори 1
BEGIN;
UPDATE deadlock_test SET val = 11 WHERE id = 1;

-- [B] блок строки 2
BEGIN;
UPDATE deadlock_test SET val = 21 WHERE id = 2;

-- [A] пытка взять строку 2
UPDATE deadlock_test SET val = 12 WHERE id = 2;

-- [B] пытка взять строку 1(цикл блок)
-- expect: error deadlock
UPDATE deadlock_test SET val = 22 WHERE id = 1;

-- [A]
ROLLBACK;

-- [B]
ROLLBACK;

-- [cleanup]
DROP TABLE deadlock_test;