class CreateDcPathDcClasses < ActiveRecord::Migration
  def self.up
    create_table :dc_path_dc_classes do |t|
      t.column :dc_path_id, :integer
      t.column :dc_class_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dc_path_dc_classes
  end
end
