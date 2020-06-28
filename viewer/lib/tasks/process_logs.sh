#!/data/data/com.termux/files/usr/bin/sh
PROJECT=/data/data/com.termux/files/home/android-sinatra
BUNDLE=/data/data/com.termux/files/usr/bin/bundle
NGINX_PID=/data/data/com.termux/files/home/android-sinatra/log/nginx.pid
cd $PROJECT

TIMESTAMP=`date '+%s'`
LATEST_LOG_FILE=log/nginx.access.log.$TIMESTAMP

# logrotate
mv log/nginx.access.log $LATEST_LOG_FILE
kill -USR1 `cat $NGINX_PID`
sleep 3

$BUNDLE exec ruby -e "File.write('log/compiler.log', ''); require '$PROJECT/lib/compiler'; Compiler.new($LATEST_LOG_FILE).process"
