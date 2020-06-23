require 'sequel'
require_relative '../.test_credentials_secret' # Test environment only
require_relative './models/hits'

DB = Sequel.connect(
  adapter: :postgres,
  database: ENV['ANDROID_DATABASE_NAME'],
  host: ENV['ANDROID_DATABASE_HOST'],
  user: ENV['ANDROID_DATABASE_USER'],
  password: ENV['ANDROID_DATABASE_PASSWORD'])
