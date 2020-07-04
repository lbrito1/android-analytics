class AddIpIndexToHits < ActiveRecord::Migration[5.2]
  def change
    add_index :hits, [:created_at, :ip]
  end
end
