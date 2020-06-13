ln -s $HOME/android-sinatra/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

killlall nginx
nginx

pg_ctl -D $PREFIX/var/lib/postgresql start

bundle install --path vendor/bundle

mkdir -p tmp/puma

bundle exec ruby `which puma` --config ./config/puma.rb
