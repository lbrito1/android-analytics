require_relative '../config/db'

Sequel.extension(:migration)
Sequel::Migrator.run(DB, "db/migrations") # add target: 0 for rollback
