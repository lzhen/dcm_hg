class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :user_name, :string
      t.column :first_name, :string
      t.column :middle_name, :string
      t.column :last_name, :string
      t.column :degree, :string
      t.column :user_type, :string
      t.column :is_admin, :boolean
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
