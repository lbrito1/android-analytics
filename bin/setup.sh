WD=`pwd`
DB_NAME=`cat .env | sed -n -e 's/^DB_NAME=//p'`
DB_USERNAME=`cat .env | sed -n -e 's/^DB_USERNAME=//p'`
DB_PWD=`cat .env | sed -n -e 's/^DB_PASSWORD=//p'`
[[ -z "$DB_PWD" ]] && { echo "Failed: DB_PASSWORD was not found." ; exit 1; }

# Copy config files
ln -sf $WD/.env $WD/viewer/.env

# Add exec permissions to scripts
chmod +x ./bin/* || { echo "Failed: giving exec permission to bin/" ; exit 1; }
chmod +x ./viewer/bin/* || { echo "Failed: giving exec permission to bin/" ; exit 1; }

# Install dependencies: nginx 1.17.8 postgresql 12.3 ruby 2.6.5
pkg update -y || { echo "Failed: pkg update" ; exit 1; }
pkg install nginx postgresql ruby debianutils -y || { echo "Failed: pkg installs" ; exit 1; }

# Adds nginx config
ln -sf $WD/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

gem install bundler || { echo "Failed: gem install bundler" ; exit 1; }
BUNDLE=`which bundle`

# Init skeleton db
initdb $PREFIX/var/lib/postgresql
mkdir -p $PREFIX/var/lib/postgresql

# Start Postgres
if ! pgrep -x "postgres" > /dev/null
then
  pg_ctl -D $PREFIX/var/lib/postgresql start || { echo "Failed: starting postgresql" ; exit 1; }
fi

# Create postgres user
PSQL_SUPERUSER=`whoami`
psql -U $PSQL_SUPERUSER postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USERNAME'" | grep -q 1 \
 || psql -U $PSQL_SUPERUSER postgres -c "CREATE USER $DB_USERNAME password '$DB_PWD';" \
 || { echo "Failed: creating db user" ; exit 1; }

# # Create postgres database
# psql -U $PSQL_SUPERUSER postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 \
#  || psql -U $PSQL_SUPERUSER postgres -c "CREATE DATABASE $DB_NAME;" \
#  || { echo "Failed: creating db" ; exit 1; }

# Add permissions
psql -U $PSQL_SUPERUSER postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USERNAME;" \
  || { echo "Failed: granting privileges on table" ; exit 1; }
psql -U $PSQL_SUPERUSER postgres -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USERNAME;" \
  || { echo "Failed: granting privileges on sequences" ; exit 1; }

psql -U $PSQL_SUPERUSER postgres -c "ALTER USER $DB_USERNAME CREATEDB;" \
  || { echo "Failed: alter user with createdb" ; exit 1; }

# Prepare Nokogiri dependencies -- https://nokogiri.org/tutorials/installing_nokogiri.html#termux
HAS_NOKOGIRI=$(gem list | grep nokogiri)
if [ -z "$HAS_NOKOGIRI" ]; then
  pkg install ruby clang make pkg-config libxslt -y
  gem install nokogiri -- --use-system-libraries
else
  echo "Nokogiri already installedm skipping..."
fi

RAILS_ENV=production ./viewer/bin/setup || { echo "Failed: Rails setup" ; exit 1; }

# Adds cron, postgres and nginx init to bash file
cat $WD/bin/restart.sh >> $HOME/.bash_profile || { echo "Failed: adding services to bash_profile" ; exit 1; }

# Adds log compilation job to crontab
COMPILE_LOG_JOB="\n# Added by android-analytics bin/setup.sh script\n59 23 * * * $WD/bin/compile_logs.sh"
CRONTAB="$(crontab -l)\n$COMPILE_LOG_JOB"
echo $CRONTAB | crontab -

echo "Every day, once a day, give yourself a present."
