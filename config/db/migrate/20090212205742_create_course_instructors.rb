class CreateCourseInstructors < ActiveRecord::Migration
  def self.up
    create_table :course_instructors do |t|
      t.column :course_id, :integer
      t.column :instructor_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :course_instructors
  end
end
