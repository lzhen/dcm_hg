class AddCurrentPath < ActiveRecord::Migration
  def self.up
    add_column :users, :current_path, :integer
  end

  def self.down
    remove_column :users, :current_path, :integer
  end
end
