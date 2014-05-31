class AddOtherSpecialNeeds < ActiveRecord::Migration
  def self.up
    add_column :courses, :other_special_needs, :text
  end

  def self.down
    remove_column :courses, :other_special_needs
  end
end
