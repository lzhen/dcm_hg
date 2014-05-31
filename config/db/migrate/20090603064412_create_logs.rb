class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.column :user_id, :integer
      t.column :level, :integer
      t.column :remote_ip, :string
      t.column :referer, :string
      t.column :request, :string
      t.column :method, :string
      t.column :user_agent, :string
      t.column :message, :string
      t.column :controller, :string, :limit => 100
      t.column :action, :string, :limit => 100
      t.column :created_at, :timestamp
    end
  end

  def self.down
    drop_table :logs
  end
end
