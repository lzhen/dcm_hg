class CreateExternalCourseProficiencies < ActiveRecord::Migration
  def self.up
    create_table :external_course_proficiencies do |t|
      t.integer :external_course_id
      t.integer :proficiency_id

      t.timestamps
    end
    
    ExternalCourseProficiency.create_initial_history_links
  end

  def self.down
    drop_table :external_course_proficiencies
  end
end
