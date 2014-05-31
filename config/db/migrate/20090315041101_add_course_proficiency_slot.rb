class AddCourseProficiencySlot < ActiveRecord::Migration
  def self.up
    add_column :course_proficiencies, :slot, :integer
  end

  def self.down
    remove_column :course_proficiencies, :slot
  end
end
