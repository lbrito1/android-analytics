require 'sequel'
require_relative '../.test_credentials_secret' # Test environment only

DB = Sequel.connect(
  adapter: :postgres,
  database: ENV['ANDROID_DATABASE_NAME'],
  host: ENV['ANDROID_DATABASE_HOST'],
  user: ENV['ANDROID_DATABASE_USER'],
  password: ENV['ANDROID_DATABASE_PASSWORD'])

require_relative '../app/models/hits'
