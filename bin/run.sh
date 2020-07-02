BUNDLE=`which bundle`

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
