DB_NAME=`cat ../.env | sed -n -e 's/^DB_NAME=//p'`
DB_USERNAME=`cat ../.env | sed -n -e 's/^DB_USERNAME=//p'`
DB_PWD=`cat ../.env | sed -n -e 's/^DB_PASSWORD=//p'`
[[ -z "$DB_NAME" ]] && { echo "Failed: DB_NAME was not found." ; exit 1; }
[[ -z "$DB_USERNAME" ]] && { echo "Failed: DB_USERNAME was not found." ; exit 1; }
[[ -z "$DB_PWD" ]] && { echo "Failed: DB_PWD was not found." ; exit 1; }
