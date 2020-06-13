nginx -c $HOME/android-sinatra/config/nginx.conf

pg_ctl -D $PREFIX/var/lib/postgresql start

bundle install --path vendor/bundle

mkdir -p tmp/puma

bundle exec ruby `which puma` --config ./config/puma.rb
