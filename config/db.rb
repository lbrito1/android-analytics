require 'sequel'
require 'byebug'

DB = Sequel.connect(
  adapter: :postgres,
  database: 'android_analytics_production',
  host: 'localhost',
  user: 'android_analytics',
  password: ENV['ANDROID_DATABASE_PASSWORD'])

require_relative '../app/models/hits'
