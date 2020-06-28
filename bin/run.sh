export SINATRA_TOKEN=xxx

BUNDLE=`which bundle`

ln -sf $HOME/android-sinatra/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

killall nginx
nginx

if ! pgrep -x "postgres" > /dev/null
then
  echo "Starting postgres..."
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi
$BUNDLE install --path vendor/bundle

mkdir -p tmp/puma

$BUNDLE exec ruby `which puma` --config ./config/puma.rb
