WD=`pwd`
DB_USERNAME=android_analytics
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
psql -U $PSQL_SUPERUSER postgres -c "CREATE USER $DB_USERNAME password '$DB_PWD';" \
  || { echo "Failed: creating db user" ; exit 1; }

./viewer/bin/setup || { echo "Failed: Rails setup" ; exit 1; }

# Adds cron, postgres and nginx init to bash file
cat $WD/bin/restart.sh >> $HOME/.bash_profile || { echo "Failed: adding services to bash_profile" ; exit 1; }

# Adds log compilation job to crontab
COMPILE_LOG_JOB="\n# Added by android-analytics bin/setup.sh script\n59 23 * * * $WD/bin/compile_logs.sh"
CRONTAB="$(crontab -l)\n$COMPILE_LOG_JOB"
echo $CRONTAB | crontab -

echo "Every day, once a day, give yourself a present."
