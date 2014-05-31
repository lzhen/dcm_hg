class Right < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :prefix, :user_id, :name
  
  RIGHTS_NAMES = [
    ["Editor","Editor"]
    ].freeze
    
end
