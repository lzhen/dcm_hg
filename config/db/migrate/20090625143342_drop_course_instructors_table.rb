class DropCourseInstructorsTable < ActiveRecord::Migration
  def self.up
     drop_table :course_instructors
  end

  def self.down
    create_table :course_instructors do |t|
      t.column :course_id, :integer
      t.column :instructor_id, :integer

      t.timestamps
    end
  end
end
