class ExternalCourseProficiency < ActiveRecord::Base
  
  belongs_to :external_course
  belongs_to :proficiency
  
  # this will be run once - from migration to setup initial history links
  def self.create_initial_history_links
    external_history_courses = ExternalCourse.find(:all)
    external_history_courses.each do |c|
      history_prof = Proficiency.find(:first, :conditions => "name='History and Theory' and level='#{c.level}'")
      ExternalCourseProficiency.create( :external_course_id => c.id, :proficiency_id => history_prof.id )
    end
  end

end

