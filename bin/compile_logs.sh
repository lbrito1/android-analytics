#!/data/data/com.termux/files/usr/bin/sh
PROJECT=/data/data/com.termux/files/home/android-analytics
BUNDLE=/data/data/com.termux/files/usr/bin/bundle
NGINX_PID=/data/data/com.termux/files/home/android-analytics/log/nginx.pid

cd $PROJECT

mkdir -p log/old
TIMESTAMP=$(date +%Y%m%d_%H%M%S%Z)
LATEST_LOG_FILE=log/old/nginx.access.log.$TIMESTAMP

# logrotate
mv log/nginx.access.log $LATEST_LOG_FILE
kill -USR1 `cat $NGINX_PID`
sleep 3

mkdir -p log/debug
touch log/debug/"$TIMESTAMP"_start
$BUNDLE exec ruby -e "require '$PROJECT/app/compiler'; Compiler.new('$LATEST_LOG_FILE').process"
touch log/debug/"$TIMESTAMP"_finish
