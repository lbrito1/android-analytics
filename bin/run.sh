BUNDLE=`which bundle`

# Copy config files
ln -sf `pwd`/config/nginx.conf $PREFIX/etc/nginx/nginx.conf
ln -sf `pwd`/.env `pwd`/viewer/.env

# Restart nginx
killall nginx
nginx

# Restart postgresql
if ! pgrep -x "postgres" > /dev/null
then
  echo "Starting postgres..."
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi

$BUNDLE install --path vendor/bundle
