echo -e $(date -u) "\t[Beginning android-analytics setup]"
WD=`pwd`

# DB settings
echo -e $(date -u) "\t[Loading envs]"
source $WD/.env
[[ -z "$DB_NAME" ]] && { echo -e $(date -u) "\t[Error] DB_NAME was not found." ; exit 1; }
[[ -z "$DB_USERNAME" ]] && { echo -e $(date -u) "\t[Error] DB_USERNAME was not found." ; exit 1; }
[[ -z "$DB_PASSWORD" ]] && { echo -e $(date -u) "\t[Error] DB_PASSWORD was not found." ; exit 1; }

# Copy config files
ln -sf $WD/.env $WD/viewer/.env

# Add exec permissions to scripts
echo -e $(date -u) "\t[Adding execution permission to scripts]"
chmod +x ./bin/* || { echo -e $(date -u) "\t[Error] Failed giving exec permission to bin/" ; exit 1; }
chmod +x ./viewer/bin/* || { echo -e $(date -u) "\t[Error] Failed giving exec permission to bin/" ; exit 1; }

# Install dependencies: nginx 1.17.8 postgresql 12.3 ruby 2.6.5
echo -e $(date -u) "\t[Installing pkg dependencies]"
pkg update -y || { echo -e $(date -u) "\t[Error] Failed pkg update" ; exit 1; }
pkg install nginx postgresql ruby debianutils -y || { echo -e $(date -u) "\t[Error] Failed pkg installs" ; exit 1; }

# Adds nginx config
ln -sf $WD/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

echo -e $(date -u) "\t[Installing Ruby gem dependencies]"
gem install bundler || { echo -e $(date -u) "\t[Error] Failed gem install bundler" ; exit 1; }
bundle install

# Init skeleton db
echo -e $(date -u) "\t[Initializing skeleton db]"
initdb $PREFIX/var/lib/postgresql
mkdir -p $PREFIX/var/lib/postgresql

# Start Postgres and Nginx
echo -e $(date -u) "\t[Starting postgres and nginx]"
mkdir -p log
$WD/bin/restart.sh || { echo -e $(date -u) "\t[Error] Failed starting nginx or postgres." ; exit 1; }
if ! pgrep -x "nginx" > /dev/null
then
  echo -e $(date -u) "\t[Error] Failed starting nginx. If you don't have SSL certs, remove ssl-related settings from config/nginx.conf (listen 8443 ssl; ssl_certificate and ssl_certificate_key)." ; exit 1;
else
  nginx -s reload
fi

# Create postgres user
echo -e $(date -u) "\t[Creating Postgres user]"
PSQL_SUPERUSER=`whoami`
psql -U $PSQL_SUPERUSER postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USERNAME'" | grep -q 1 \
 || psql -U $PSQL_SUPERUSER postgres -c "CREATE USER $DB_USERNAME password '$DB_PASSWORD';" \
 || { echo -e $(date -u) "\t[Error] Failed creating db user" ; exit 1; }


# Add createdb permissions
echo -e $(date -u) "\t[Adding permissions to Postgres user]"
psql -U $PSQL_SUPERUSER postgres -c "ALTER USER $DB_USERNAME CREATEDB;" \
  || { echo -e $(date -u) "\t[Error] Failed alter user with createdb" ; exit 1; }
psql -U $PSQL_SUPERUSER postgres -c "CREATEDB $DB_NAME;"

# Create table
psql -U $PSQL_SUPERUSER postgres -c $DB_NAME < "$WD/db/structure.sql" $DB_USERNAME \
  || { echo -e $(date -u) "\t[Error] Failed creating tables" ; exit 1; }

# Add table permission
psql -U $PSQL_SUPERUSER postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USERNAME;" \
  || { echo -e $(date -u) "\t[Error] Failed granting privileges on table" ; exit 1; }
psql -U $PSQL_SUPERUSER postgres -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USERNAME;" \
  || { echo -e $(date -u) "\t[Error] Failed granting privileges on sequences" ; exit 1; }

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
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production ./viewer/bin/setup || { echo -e $(date -u) "\t[Error] Failed Rails setup" ; exit 1; }

# Adds cron, postgres and nginx init to bash file
echo -e $(date -u) "\t[Adding services to bash_profile]"
cat $WD/bin/restart.sh >> $HOME/.bash_profile || { echo -e $(date -u) "\t[Error] Failed adding services to bash_profile" ; exit 1; }

# Adds log compilation job to crontab
echo -e $(date -u) "\t[Updating crontab]"
crontab -l > crontab_tmp
echo -e "\n# Added by android-analytics bin/setup.sh script\n59 23 * * * $WD/bin/compile_logs.sh" >> crontab_tmp
crontab crontab_tmp
rm crontab_tmp

echo -e $(date -u) "\t[android-analytics installation finished.]"
echo -e "\n\n\"Every day, once a day, give yourself a present.\"\n\n"
