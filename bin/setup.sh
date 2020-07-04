echo -e $(date -u) "\t[Beginning android-analytics setup]"
WD=`pwd`

# DB settings
echo -e $(date -u) "\t[Loading envs]"
source $WD/.env
[[ -z "$DB_NAME" ]] && { echo "Failed: DB_NAME was not found." ; exit 1; }
[[ -z "$DB_USERNAME" ]] && { echo "Failed: DB_USERNAME was not found." ; exit 1; }
[[ -z "$DB_PASSWORD" ]] && { echo "Failed: DB_PASSWORD was not found." ; exit 1; }

# Copy config files
ln -sf $WD/.env $WD/viewer/.env

# Add exec permissions to scripts
echo -e $(date -u) "\t[Adding execution permission to scripts]"
chmod +x ./bin/* || { echo "Failed: giving exec permission to bin/" ; exit 1; }
chmod +x ./viewer/bin/* || { echo "Failed: giving exec permission to bin/" ; exit 1; }

# Install dependencies: nginx 1.17.8 postgresql 12.3 ruby 2.6.5
echo -e $(date -u) "\t[Installing pkg dependencies]"
pkg update -y || { echo "Failed: pkg update" ; exit 1; }
pkg install nginx postgresql ruby debianutils -y || { echo "Failed: pkg installs" ; exit 1; }

# Adds nginx config
ln -sf $WD/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

echo -e $(date -u) "\t[Installing Ruby gem dependencies]"
gem install bundler || { echo "Failed: gem install bundler" ; exit 1; }
BUNDLE=`which bundle`

# Init skeleton db
echo -e $(date -u) "\t[Initializing skeleton db]"
initdb $PREFIX/var/lib/postgresql
mkdir -p $PREFIX/var/lib/postgresql

# Start Postgres
echo -e $(date -u) "\t[Starting Postgres]"
if ! pgrep -x "postgres" > /dev/null
then
  pg_ctl -D $PREFIX/var/lib/postgresql start || { echo "Failed: starting postgresql" ; exit 1; }
fi

# Create postgres user
echo -e $(date -u) "\t[Creating Postgres user]"
PSQL_SUPERUSER=`whoami`
psql -U $PSQL_SUPERUSER postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USERNAME'" | grep -q 1 \
 || psql -U $PSQL_SUPERUSER postgres -c "CREATE USER $DB_USERNAME password '$DB_PASSWORD';" \
 || { echo "Failed: creating db user" ; exit 1; }

# Add permissions
echo -e $(date -u) "\t[Adding permissions to Postgres user]"
psql -U $PSQL_SUPERUSER postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USERNAME;" \
  || { echo "Failed: granting privileges on table" ; exit 1; }
psql -U $PSQL_SUPERUSER postgres -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USERNAME;" \
  || { echo "Failed: granting privileges on sequences" ; exit 1; }
psql -U $PSQL_SUPERUSER postgres -c "ALTER USER $DB_USERNAME CREATEDB;" \
  || { echo "Failed: alter user with createdb" ; exit 1; }

# Prepare Nokogiri dependencies -- https://nokogiri.org/tutorials/installing_nokogiri.html#termux
echo -e $(date -u) "\t[Preparing Nokogiri gem]"
HAS_NOKOGIRI=$(gem list | grep nokogiri)
if [ -z "$HAS_NOKOGIRI" ]; then
  pkg install ruby clang make pkg-config libxslt -y
  gem install nokogiri -- --use-system-libraries
else
  echo "Nokogiri already installed, skipping..."
fi

echo -e $(date -u) "\t[Preparing Rails app (also loads DB schema + seeds)]"
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production ./viewer/bin/setup || { echo "Failed: Rails setup" ; exit 1; }

# Adds cron, postgres and nginx init to bash file
echo -e $(date -u) "\t[Adding services to bash_profile]"
cat $WD/bin/restart.sh >> $HOME/.bash_profile || { echo "Failed: adding services to bash_profile" ; exit 1; }

# Adds log compilation job to crontab
echo -e $(date -u) "\t[Updating crontab]"
crontab -l > crontab_tmp
echo -e "\n# Added by android-analytics bin/setup.sh script\n59 23 * * * $WD/bin/compile_logs.sh" >> crontab_tmp
crontab crontab_tmp
rm crontab_tmp

echo -e $(date -u) "\t[android-analytics installation finished.]"
echo -e "\n\n\"Every day, once a day, give yourself a present.\"\n\n"
