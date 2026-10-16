INSERT INTO restaurants (name, address, type, area)
VALUES ('Теремок', 'ул. Другая, 99', 'фастфуд', 'Другой');

INSERT INTO dishes (restaurant_id, name, category, ingredients, price)
VALUES (1, 'Плохое блюдо', 'суп', 'вода', -100);

INSERT INTO dishes (restaurant_id, name, category, ingredients, price)
VALUES (9999, 'Сирота', 'суп', 'вода', 100);