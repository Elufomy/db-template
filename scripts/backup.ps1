# 1. дамп базы app в файл backup.dump
docker compose exec -T db pg_dump -U postgres -d app -Fc -f /tmp/backup.dump

# 2. копипаста дамп из контейнера на хост
docker compose cp db:/tmp/backup.dump ./backup.dump

# 3. чистая база app_restore
docker compose exec -T db psql -U postgres -c "DROP DATABASE IF EXISTS app_restore;"
docker compose exec -T db psql -U postgres -c "CREATE DATABASE app_restore;"

# 4. востановление дамп в новую базу
docker compose cp ./backup.dump db:/tmp/backup.dump
docker compose exec -T db pg_restore -U postgres -d app_restore /tmp/backup.dump

# 5. проверка данных
docker compose exec -T db psql -U postgres -d app_restore -c "SELECT count(*) FROM orders;"