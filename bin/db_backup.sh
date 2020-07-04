source .env
[[ -z "$DB_NAME" ]] && { echo "Failed: DB_NAME was not found. (source .env first)" ; exit 1; }
[[ -z "$DB_USERNAME" ]] && { echo "Failed: DB_USERNAME was not found." ; exit 1; }
[[ -z "$DB_PASSWORD" ]] && { echo "Failed: DB_PASSWORD was not found." ; exit 1; }

pg_dump -U $DB_USERNAME -d $DB_NAME --data-only --column-inserts -t blazer_queries > backup.sql
