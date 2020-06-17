class AddConstraints < Sequel::Migration
  def up
    alter_table :hits do
      add_constraint(:url_length) { char_length(:url) < 256 }
      add_constraint(:ip_length) { char_length(:ip) < 16 }
      add_constraint(:user_agent_length) { char_length(:user_agent) < 128 }
    end
  end

  def down
    alter_table :hits do
      drop_constraint(:url_length)
      drop_constraint(:ip_length)
      drop_constraint(:user_agent_length)
    end
  end
end
