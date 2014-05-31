class ExternalInstance < ActiveRecord::Base
  
  belongs_to :external_course
  belongs_to :semester
  
  has_many :path_external_instances, :dependent => :destroy
  has_many :paths, :through => :path_external_instances
  
end
