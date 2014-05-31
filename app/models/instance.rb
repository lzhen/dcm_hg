class Instance < ActiveRecord::Base
  
  belongs_to :course
  belongs_to :semester
  
  has_many :path_instances, :dependent => :destroy
  has_many :paths, :through => :path_instances
  
  validates_presence_of  :course_id, :semester_id# , :instructor_id, :days, :start_time, :end_time, :location
  
  def self.create_instance(instance_params, course, semester)
    a_class = Instance.new(instance_params)
    a_class.course_id = course
    a_class.semester_id = semester
    a_class.save
  end
end
