class RemoveRequested < ActiveRecord::Migration
  def self.up
    remove_column :courses, :is_requested
    remove_column :courses, :unit
    remove_column :courses, :is_general
    remove_column :courses, :facility
    rename_column :courses, :special_needs, :facility_needs
    remove_column :courses, :special_incoming_proficiencies
    remove_column :courses, :special_outgoing_proficiencies
  end

  def self.down
    add_column :courses, :special_outgoing_proficiencies, :string
    add_column :courses, :special_incoming_proficiencies, :string
    rename_column :courses, :facility_needs, :special_needs
    add_column :courses, :facility, :string
    add_column :courses, :is_general, :boolean
    add_column :courses, :unit, :string
    add_column :courses, :is_requested, :boolean
  end
end
