export SINATRA_TOKEN=xxx

ln -sf $HOME/android-sinatra/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

if pgrep -x "nginx" > /dev/null
then
  echo "Reloading nginx config..."
  nginx -s reload
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

mkdir -p tmp/puma

bundle exec ruby `which puma` --config ./config/puma.rb
