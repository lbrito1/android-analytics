class CreateHitsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :hits_tables do |t|
      primary_key :id
      DateTime :created_at
      String :url,        size: 256
      String :ip,         size: 32
      String :user_agent, size: 256
      String :country,    size: 128
      String :region,     size: 128
      String :city,       size: 128
      String :device,     size: 32
      String :os,         size: 32
    end
  end
end
