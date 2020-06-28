class AddLatLong < Sequel::Migration
  def up
    alter_table :hits do
      add_column :lat, BigDecimal
      add_column :long, BigDecimal
    end
  end

  def down
    alter_table :hits do
      drop_column :lat, BigDecimal
      drop_column :long, BigDecimal
    end
  end
end
