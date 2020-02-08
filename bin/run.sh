bundle install --path vendor/bundle

mkdir -p tmp/puma

bundle exec puma --config config/puma.rb
