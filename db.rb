require 'sequel'

# Test environment only
require_relative '.test_credentials_secret'

DB = Sequel.connect(
  adapter: :postgres,
  database: ENV['ANDROID_DATABASE_NAME'],
  host: ENV['ANDROID_DATABASE_HOST'],
  user: ENV['ANDROID_DATABASE_USER'],
  password: ENV['ANDROID_DATABASE_PASSWORD'])
