class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :subject
      t.text :details
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
