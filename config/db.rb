require 'sequel'
require_relative '../.test_credentials_secret' # Test environment only

DB = Sequel.connect(
  adapter: :postgres,
  database: android_analytics_production,
  host: localhost,
  user: android_analytics
  password: ENV['ANDROID_DATABASE_PASSWORD'])

require_relative '../app/models/hits'
