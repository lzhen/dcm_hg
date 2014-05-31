class CreatePathExternalInstances < ActiveRecord::Migration
  def self.up
    create_table :path_external_instances do |t|
      t.integer :path_id
      t.integer :external_instance_id

      t.timestamps
    end
  end

  def self.down
    drop_table :path_external_instances
  end
end
