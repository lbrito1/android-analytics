ln -sf $HOME/android-sinatra/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

if pgrep -x "nginx" > /dev/null
then
  echo "Reloading nginx config..."
  nginxc -s reload
else
  echo "Starting nginx..."
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi
nginx

if ! pgrep -x "postgres" > /dev/null
then
  echo "Starting postgres..."
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi

bundle install --path vendor/bundle
