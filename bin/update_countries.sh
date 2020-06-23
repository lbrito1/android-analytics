#!/data/data/com.termux/files/usr/bin/sh
PROJECT=/data/data/com.termux/files/home/android-sinatra
BUNDLE=/data/data/com.termux/files/usr/bin/bundle
cd $PROJECT

$BUNDLE exec ruby -e "File.write('log/compiler.log', ''); require '$PROJECT/app/compiler'; Compiler.update_geo_info"
