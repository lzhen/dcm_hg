class CreateRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.integer :user_id
      t.string :prefix
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :rights
  end
end
