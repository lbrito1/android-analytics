class CreateHitsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :hits_tables do |t|
      t.string :url,        limit: 256
      t.string :ip,         limit: 32
      t.string :user_agent, limit: 256
      t.string :country,    limit: 128
      t.string :region,     limit: 128
      t.string :city,       limit: 128
      t.string :device,     limit: 32
      t.string :os,         limit: 32
      t.decimal :lat,       precision: 10, scale: 6
      t.decimal :long,      precision: 10, scale: 6

      t.datetime :created_at
    end
  end
end
