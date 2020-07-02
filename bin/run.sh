BUNDLE=`which bundle`

# Restart nginx
if ! pgrep -x "nginx" > /dev/null
then
  nginx
else
  nginx -s reload
fi

# Restart postgresql
if ! pgrep -x "postgres" > /dev/null
then
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi

$BUNDLE install --path vendor/bundle
