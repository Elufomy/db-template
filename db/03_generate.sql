INSERT INTO restaurants (name, address, type, rating, area)
SELECT
    'Ресторан №' || i,
    'ул. Генеральная, ' || i,
    (ARRAY['кафе', 'ресторан', 'фастфуд'])[1 + floor(random() * 3)::int],
    round((random() * 4 + 1)::numeric, 1),
    (ARRAY['Тверской', 'Арбат', 'Хамовники', 'Ленинский', 'Пресненский'])[1 + floor(random() * 5)::int]
FROM generate_series(1, 1000) AS i;

INSERT INTO couriers (courier_number, full_name, phone, transport_type, district, status)
SELECT
    'K-' || (1000 + i),
    'Курьер ' || i,
    '+7-900-' || lpad(i::text, 7, '0'),
    (ARRAY['пеший', 'машина', 'велосипед'])[1 + floor(random() * 3)::int],
    (ARRAY['Тверской', 'Арбат', 'Хамовники', 'Ленинский', 'Пресненский'])[1 + floor(random() * 5)::int],
    (ARRAY['свободен', 'занят', 'выходной'])[1 + floor(random() * 3)::int]
FROM generate_series(1, 1000) AS i;

INSERT INTO dishes (restaurant_id, name, category, ingredients, calories, weight_g, price)
SELECT
    (i % 1000) + 1, 
    'Блюдо №' || i,
    (ARRAY['салат', 'суп', 'горячее', 'десерт', 'напиток'])[1 + floor(random() * 5)::int],
    'Ингредиент А, Ингредиент Б',
    floor(random() * 800 + 50)::int,
    floor(random() * 400 + 50)::int,
    round((random() * 2000 + 100)::numeric, 2)
FROM generate_series(1, 1000) AS i;

INSERT INTO orders (customer_email, restaurant_id, courier_id, address, status, min_check)
SELECT
    'client' || i || '@test.ru',
    (i % 1000) + 1,
    (i % 1000) + 1,
    'ул. Заказная, ' || i,
    (ARRAY['новый', 'готовится', 'в пути', 'доставлен'])[1 + floor(random() * 4)::int],
    300.00
FROM generate_series(1, 1000) AS i;

INSERT INTO order_items (order_id, dish_id, quantity, price_at_order)
SELECT
    (i % 1000) + 1, 
    ((i + 50) % 1000) + 1,
    floor(random() * 3 + 1)::int, 
    round((random() * 500 + 100)::numeric, 2)
FROM generate_series(1, 1000) AS i;