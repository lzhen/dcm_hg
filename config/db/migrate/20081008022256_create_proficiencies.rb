class CreateProficiencies < ActiveRecord::Migration
  def self.up
    create_table :proficiencies do |t|
      t.column :name, :string
      t.column :level, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :proficiencies
  end
end
