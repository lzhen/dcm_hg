class CreateDcClasses < ActiveRecord::Migration
  def self.up
    create_table :dc_classes do |t|
      t.column :course_id, :integer
      t.column :semester_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :dc_classes
  end
end
