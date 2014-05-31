class RemoveIsPlanned < ActiveRecord::Migration
  def self.up
    remove_column :courses, :is_planned
  end

  def self.down
    add_column :courses, :is_planned, :boolean
  end
end
