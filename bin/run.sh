ln -sf $HOME/android-sinatra/config/nginx.conf $PREFIX/etc/nginx/nginx.conf

killall nginx
nginx

# TODO check if psql running
pg_ctl -D $PREFIX/var/lib/postgresql start

bundle install --path vendor/bundle

mkdir -p tmp/puma

bundle exec ruby `which puma` --config ./config/puma.rb
