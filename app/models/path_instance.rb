class PathInstance < ActiveRecord::Base
  
  belongs_to :path
  belongs_to :instance

  validates_presence_of :path_id, :instance_id
    
end
