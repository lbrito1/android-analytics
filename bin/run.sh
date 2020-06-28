ANDROID_SANDBOX_DATABASE_PASSWORD=changeme

BUNDLE=`which bundle`
PUMA=`which puma`
ln -sf `pwd`/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

killall nginx
nginx

if ! pgrep -x "postgres" > /dev/null
then
  echo "Starting postgres..."
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi
$BUNDLE install --path vendor/bundle

mkdir -p tmp/pids
mkdir -p tmp/puma

RAILS_ENV=production $BUNDLE exec $PUMA -C config/puma.rb
