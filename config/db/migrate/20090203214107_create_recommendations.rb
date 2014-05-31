class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.column :course_id, :integer
      t.column :user_id, :integer
      t.column :recommendation_type, :string
      t.column :recommendation_text, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
