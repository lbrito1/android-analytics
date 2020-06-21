class AddMetadataToHits < Sequel::Migration
  def up
    alter_table :hits do
      drop_constraint(:ip_length)
      add_constraint(:ip_length_annonymized) { char_length(:ip) < 33 }
    end
  end

  def down
    alter_table :hits do
      drop_constraint(:ip_length_annonymized)
    end
  end
end

