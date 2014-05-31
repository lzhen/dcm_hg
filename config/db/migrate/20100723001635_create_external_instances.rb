class CreateExternalInstances < ActiveRecord::Migration
  def self.up
    create_table :external_instances do |t|
      t.integer :external_course_id
      t.integer :semester_id

      t.timestamps
    end
  end

  def self.down
    drop_table :external_instances
  end
end
