require_relative 'db'

puts 'Running one-time DB creation...'

DB.create_table :test_entry do
  primary_key :id
  String :test_string
end

puts 'Done.'
