LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | grep '192')
BUNDLE=`which bundle`
PUMA=`which puma`

$BUNDLE install --path vendor/bundle

mkdir -p tmp/pids
mkdir -p tmp/puma

RAILS_ENV=production $BUNDLE exec $PUMA -C config/puma.rb -b tcp://$LOCAL_IP:3000
