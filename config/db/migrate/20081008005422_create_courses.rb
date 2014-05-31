class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.column :title, :string
      t.column :unit, :string
      t.column :prefix, :string
      t.column :number, :integer
      t.column :description, :string
      t.column :credit_hours, :integer
      t.column :is_existing, :boolean
      t.column :is_planned, :boolean
      t.column :is_requested, :boolean
      t.column :anticipated_start_date, :date
      t.column :classification, :string
      t.column :is_general, :boolean
      t.column :frequency, :string
      t.column :facility, :string
      t.column :special_needs, :string
      t.column :total_seats, :integer
      t.column :reserved_seats, :integer
      t.column :notes, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
