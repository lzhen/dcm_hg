class Recommendation < ActiveRecord::Base
  
  belongs_to :course
  #belongs_to :user
  
  
  #RECOMMENDATION_TYPE_OPTIONS = [
 	#  ["Please Select the Type of Recommendation", ""],
 	#  ["Student Recommendation", "Student Recommendation"],
 	#  ["Faculty Recommendation", "Faculty Recommendation"],
 	#  ["Department Recommendation", "Department Recommendation"]
 	#].freeze

 	#RECOMMENDATION_TYPE_OPTION_LIST = ["", "Student Recommendation", "Faculty Recommendation", "Department Recommendation"]
end
