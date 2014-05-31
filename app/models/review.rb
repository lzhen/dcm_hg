class Review < ActiveRecord::Base
  
  belongs_to :student, :class_name => "User", :foreign_key => "student_id"
  belongs_to :course
  
  validates_presence_of :review_text
  
end
