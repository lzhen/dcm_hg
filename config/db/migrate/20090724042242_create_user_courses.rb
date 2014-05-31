class CreateUserCourses < ActiveRecord::Migration
  def self.up
    create_table :user_courses do |t|
      t.column :user_id, :integer
      t.column :course_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :user_courses
  end
end
