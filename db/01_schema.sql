-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.

CREATE TABLE restaurants (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL UNIQUE,
    address     text NOT NULL,
    type        text NOT NULL CHECK (type IN ('кафе', 'ресторан', 'фастфуд')),
    phone       text UNIQUE,
    rating      numeric(2,1) CHECK (rating BETWEEN 0 AND 5),
    area        text NOT NULL
);

CREATE TABLE dishes (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id       integer NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name                text NOT NULL,
    category            text NOT NULL CHECK (category IN ('завтрак', 'салат', 'суп', 'горячее','десерт', 'напиток', 'фастфуд')),
    ingredients         text NOT NULL,
    calories            integer CHECK (calories >= 0),
    proteins            numeric(4,1) CHECK (proteins >= 0),
    fats                numeric(4,1) CHECK (fats >= 0),
    carbs               numeric(4,1) CHECK (carbs >= 0),
    weight_g            integer CHECK (weight_g > 0),
    price               numeric(10,2) CHECK (price > 0),
    is_available        boolean NOT NULL DEFAULT true
);

CREATE TABLE couriers(
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    courier_number      text NOT NULL UNIQUE,
    full_name           text NOT NULL,
    phone               text UNIQUE,
    transport_type      text NOT NULL CHECK (transport_type IN ('пеший', 'машина', 'велосипед')),
    district            text NOT NULL,
    status              text NOT NULL DEFAULT 'свободен' CHECK (status IN ('свободен', 'занят', 'выходной')),
    hired_at            date NOT NULL DEFAULT current_date
);

CREATE TABLE orders (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_email      text NOT NULL,
    restaurant_id       integer NOT NULL REFERENCES restaurants(id) ON DELETE RESTRICT,
    courier_id          integer REFERENCES couriers(id) ON DELETE SET NULL,
    address             text NOT NULL,
    status              text NOT NULL DEFAULT 'новый' CHECK (status IN ('новый', 'обрабатывается', 'готовится', 'в пути', 'отменён', 'доставлен')),
    created_at          timestamptz NOT NULL DEFAULT now(),
    min_check           numeric(10,2) CHECK (min_check >= 0)
);

CREATE TABLE order_items (
    order_id        integer NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    dish_id         integer NOT NULL REFERENCES dishes(id) ON DELETE RESTRICT,
    quantity        integer NOT NULL CHECK (quantity > 0),
    price_at_order  numeric(10,2) NOT NULL CHECK (price_at_order > 0),
    PRIMARY KEY (order_id, dish_id)
);