source ./db_envs.sh

pg_dump -U $DB_USERRNAME --data-only --column-inserts -t blazer_queries > ../backup.sql


