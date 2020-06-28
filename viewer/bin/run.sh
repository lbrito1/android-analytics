BUNDLE=`which bundle`
PUMA=`which puma`

$BUNDLE install --path vendor/bundle

mkdir -p tmp/pids
mkdir -p tmp/puma

RAILS_ENV=production $BUNDLE exec $PUMA -C config/puma.rb -b tcp://192.168.0.23:3000

