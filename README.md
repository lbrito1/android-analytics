## Setting up

Need to run `export SINATRA_TOKEN=xxx`

### NGINX

Testing helper: https://nginx.viraptor.info/

### Proxying client ip

proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

## Creating DB user and database

### Development

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

Then run `bundle exec ruby create_db.rb`

## Testing POST

Test POST/insert: `curl localhost:4567 -XPOST -d 'word=foobar'`

