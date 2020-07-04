[[ -z "$DB_NAME" ]] && { echo "Failed: DB_NAME was not found. (source .env first)" ; exit 1; }
[[ -z "$DB_USERNAME" ]] && { echo "Failed: DB_USERNAME was not found." ; exit 1; }
[[ -z "$DB_PWD" ]] && { echo "Failed: DB_PWD was not found." ; exit 1; }

pg_dump -U $DB_USERRNAME --data-only --column-inserts -t blazer_queries > ../backup.sql


