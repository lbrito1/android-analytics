export ANDROID_SANDBOX_DATABASE_PASSWORD=42sAgV41XdHr1NMCPy0wHx4QKviTnIWQ
# export BLAZER_DATABASE_URL=postgres://android_analytics:$ANDROID_SANDBOX_DATABASE_PASSWORD@localhost:5432/android_analytics_production

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

RAILS_ENV=development $BUNDLE exec $PUMA -C config/puma.rb
