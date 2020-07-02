require_relative 'boot'

DB = Sequel.connect(
  adapter: :postgres,
  database: 'android_analytics_production',
  host: 'localhost',
  user: 'android_analytics',
  password: ENV['ANDROID_DATABASE_PASSWORD'])

require_relative '../app/models/hits'
