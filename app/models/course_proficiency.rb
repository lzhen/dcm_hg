class CourseProficiency < ActiveRecord::Base
  
  belongs_to :course
  belongs_to :proficiency
  
  validates_presence_of :proficiency_direction, :course_id, :proficiency_id
  
  def self.create_course_proficiency(direction, course, proficiency, slot)
    return nil if CourseProficiency.exists?(:course_id => course, :proficiency_id => proficiency, :slot => slot)
    course_proficiency = CourseProficiency.create(:course_id => course, :proficiency_id => proficiency, :proficiency_direction => direction, :slot => slot)
  end
  
  def set_proficiency(new_proficiency)
    self.proficiency_id = new_proficiency.id
    unless self.save
      logger.warn "error on set_proficiency"
    end
  end
  
end
