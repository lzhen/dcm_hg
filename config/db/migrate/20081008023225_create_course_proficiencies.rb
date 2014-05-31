class CreateCourseProficiencies < ActiveRecord::Migration
  def self.up
    create_table :course_proficiencies do |t|
      t.column :course_id, :integer
      t.column :proficiency_id, :integer
      t.column :proficiency_direction, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :course_proficiencies
  end
end
