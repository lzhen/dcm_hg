class AddIsEventEditor < ActiveRecord::Migration
  def self.up
    add_column :users, :is_event_editor, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_event_editor
  end
end
