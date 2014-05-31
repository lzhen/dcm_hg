class AddSpecialProficiencies < ActiveRecord::Migration
  def self.up
    add_column :courses, :special_incoming_proficiencies, :string
    add_column :courses, :special_outgoing_proficiencies, :string
  end

  def self.down
    remove_column :courses, :special_incoming_proficiencies
    remove_column :courses, :special_outgoing_proficiencies
  end
end
