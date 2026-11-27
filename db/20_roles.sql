\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

-- app_reader: только views, не таблицы
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_reader;
GRANT SELECT ON order_cards, restaurant_revenue TO app_reader;

-- app_writer: не таблицы напрямую, только бизнес-процедура
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_writer;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE assign_courier(integer, integer) TO app_writer;