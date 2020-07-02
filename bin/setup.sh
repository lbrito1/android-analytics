PSQL_SUPERUSER=`whoami`
DB_USERNAME=android_analytics
DB_PWD=`cat .env | sed -n -e 's/^ANDROID_DATABASE_PASSWORD=//p'`
[[ -z "$DB_PWD" ]] && { echo "Failed: ANDROID_DATABASE_PASSWORD was not found." ; exit 1; }

# Copy config files
ln -sf `pwd`/config/nginx.conf $PREFIX/etc/nginx/nginx.conf
ln -sf `pwd`/.env `pwd`/viewer/.env

chmod +x ./bin/* || { echo "Failed: giving exec permission to bin/" ; exit 1; }

pkg update || { echo "Failed: pkg update" ; exit 1; }

# nginx 1.17.8 postgresql 12.3 ruby 2.6.5
pkg install nginx && pkg install postgresql && pkg install ruby \
  || { echo "Failed: pkg installs" ; exit 1; }

gem install bundler || { echo "Failed: gem install bundler" ; exit 1; }
BUNDLE=`which bundle`

pg_ctl -D $PREFIX/var/lib/postgresql start || { echo "Failed: starting postgresql" ; exit 1; }

psql -U $PSQL_SUPERUSER postgres -c "CREATE USER $DB_USERNAME password '$DB_PWD';" \
  || { echo "Failed: creating db user" ; exit 1; }

cp -n .env.template .env || { echo "Failed: creating .env" ; exit 1; }

./viewer/bin/setup || { echo "Failed: Rails setup" ; exit 1; }

echo "
if ! pgrep -f 'crond' >/dev/null; then
echo '[Starting crond...]' && crond && echo '[OK]'
else
echo '[crond is running]'
fi

if ! pgrep -x 'postgres' > /dev/null
then
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi

nginx" >> $HOME/.bash_profile || { echo "Failed: adding stuff to bash_profile" ; exit 1; }


CRONTAB=$(crontab -l)
