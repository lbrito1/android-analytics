bundle install --path vendor/bundle

mkdir -p tmp/puma

ruby `which puma` --config ./config/puma.rb
