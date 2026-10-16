-- 1. дубликат названия ресторана: ожидаем ошибку UNIQUE
-- expect: error unique
INSERT INTO restaurants (name, address, type, area)
VALUES ('Теремок', 'ул. Другая, 99', 'фастфуд', 'Другой');

-- 2. отрицательная цена блюда: ожидаем ошибку CHECK
-- expect: error check
INSERT INTO dishes (restaurant_id, name, category, ingredients, price)
VALUES (1, 'Плохое блюдо', 'суп', 'вода', -100);

-- 3. несуществующий ресторан: ожидаем ошибку внешнего ключа
-- expect: error fk
INSERT INTO dishes (restaurant_id, name, category, ingredients, price)
VALUES (9999, 'Сирота', 'суп', 'вода', 100);