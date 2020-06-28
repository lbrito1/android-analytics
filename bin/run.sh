BUNDLE=`which bundle`

ln -sf `pwd`/config/nginx.conf $PREFIX/etc/nginx/nginx.conf
killall nginx
nginx

if ! pgrep -x "postgres" > /dev/null
then
  echo "Starting postgres..."
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi
$BUNDLE install --path vendor/bundle
