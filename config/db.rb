require_relative 'boot'

DB = Sequel.connect(
  adapter: :postgres,
  database: ENV['DB_NAME'],
  host: 'localhost',
  user: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD'])

require_relative '../app/models/hits'
