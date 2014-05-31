class AddHsIncomingProficiencies < ActiveRecord::Migration
  def self.up
    add_column :courses, :hs_incoming_proficiencies, :text
  end

  def self.down
    remove_column :courses, :hs_incoming_proficiencies
  end
end
