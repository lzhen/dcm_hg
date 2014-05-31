class Event < ActiveRecord::Base
  attr_accessible :title, :body, :happens_at, :photo, :delete_photo
  has_attached_file :photo,
                    :url => "/system/events/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/system/events/:attachment/:id/:style/:basename.:extension"

  before_validation :clear_photo
  
  def delete_photo=(value)
    @delete_photo = !value.to_i.zero?
  end
  
  def delete_photo
    @delete_photo
  end
  
  alias_method :delete_photo?, :delete_photo
  
  def clear_photo
    logger.debug("")
    logger.debug(">>>>> clear_photo - #{delete_photo}")
    self.photo = nil if delete_photo? && !photo.dirty?
  end
end
