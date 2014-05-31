class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :semesters do |t|
      t.column :name, :string
      t.column :year, :string
      t.column :start_date, :date
      t.column :end_date, :date

      t.timestamps
    end
  end

  def self.down
    drop_table :semesters
  end
end
