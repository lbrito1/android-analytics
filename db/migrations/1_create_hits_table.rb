class AddConstraints < Sequel::Migration
  def up
    create_table? :hits do
      primary_key :id
      DateTime :created_at
      String :url
      String :ip # convert to country later
      String :user_agent # convert to device later
    end
  end

  def down
    drop_table :hits
  end
end

