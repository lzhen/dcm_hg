class RenameDcClass < ActiveRecord::Migration
  def self.up
    rename_table :dc_classes, :instances
    rename_table :dc_paths, :paths
    rename_table :dc_path_dc_classes, :path_instances
    rename_column :path_instances, :dc_path_id, :path_id
    rename_column :path_instances, :dc_class_id, :instance_id
  end

  def self.down
    rename_table :instances, :dc_classes
    rename_table :paths, :dc_paths
    rename_table :path_instances, :dc_path_dc_classes
    rename_column :dc_path_dc_classes, :path_id, :dc_path_id
    rename_column :dc_path_dc_classes, :instance_id, :dc_class_id
  end
end
