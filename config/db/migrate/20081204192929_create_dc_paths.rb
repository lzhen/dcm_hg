class CreateDcPaths < ActiveRecord::Migration
  def self.up
    create_table :dc_paths do |t|
      t.column :student_id, :integer
      t.column :title, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :dc_paths
  end
end
