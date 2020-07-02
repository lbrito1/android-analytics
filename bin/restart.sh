# Restart crond
if ! pgrep -f 'crond' >/dev/null; then
  echo '[Starting crond...]' && crond && echo '[OK]'
else
  echo '[crond is running]'
fi

# Restart nginx
if ! pgrep -x "nginx" > /dev/null
then
  nginx
else
  nginx -s reload
fi

# Restart postgresql
if ! pgrep -x "postgres" > /dev/null
then
  pg_ctl -D $PREFIX/var/lib/postgresql start
fi
