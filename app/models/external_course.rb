class ExternalCourse < ActiveRecord::Base
  
  has_many :external_course_proficiencies, :dependent => :destroy
  has_many :proficiencies, :through => :external_course_proficiencies
  has_many :external_instances, :order => 'semester_id', :dependent => :destroy
  
  def level
    (number / 100).floor * 100
  end
  
  def shortname
    prefix + ' ' + number.to_s
  end
    
  def fullname
    prefix + ' ' + number.to_s + ' - ' + title
  end
  
end
