## Creating DB user and database

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

Test POST/insert: curl localhost:4567 -XPOST -d 'word=foobar'
