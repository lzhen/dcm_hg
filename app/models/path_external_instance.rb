class PathExternalInstance < ActiveRecord::Base
  belongs_to :path
  belongs_to :external_instance
end
