class CreateCourseProficiencies < ActiveRecord::Migration
  def self.up
    create_table :course_proficiencies do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :course_proficiencies
  end
end
