class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.column :student_id, :integer
      t.column :course_id, :integer
      t.column :review_text, :text
      t.column :recommend, :boolean, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
