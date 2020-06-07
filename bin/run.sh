bundle install --path vendor/bundle

mkdir -p tmp/puma

bundle exec ruby `which puma` --config ./config/puma.rb
