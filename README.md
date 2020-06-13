## NGINX

### cert

mkdir $HOME/nginx-ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $HOME/nginx-ssl/nginx.key -out $HOME/nginx-ssl/nginx.crt

https://xyrillian.de/thoughts/posts/how-i-run-certbot.html
```
pkg install openssl
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl

apt install nsutils
getssl

location ^~ /.well-known/acme-challenge/ {
  allow all;
    default_type "text/plain";
}
```

```
wget https://dl.eff.org/certbot-auto
mv certbot-auto ./bin/certbot-auto
chmod 0755 ./bin/certbot-auto

/usr/local/bin/certbot-auto certonly --nginx
```

### Proxying client ip

proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

## Creating DB user and database


### Test

`sudo -u postgres bash`

Then create user:

`createuser --interactive --pwprompt`

Using these creds for test env:

```ruby
ENV['ANDROID_DATABASE_NAME'] = "test"
ENV['ANDROID_DATABASE_HOST'] = "localhost"
ENV['ANDROID_DATABASE_USER'] = "test"
ENV['ANDROID_DATABASE_PASSWORD'] = "123456"
```

Then create the database:

```
sudo -u postgres bash
# psql
=# create database test;
```

### Android


## Step 2


Then run `bundle exec ruby create_db.rb`

Test POST/insert: curl localhost:4567 -XPOST -d 'word=foobar'
ndroid nginx  8080  8080  TCP   8080  8080  192.168.0.23  wanbridge
