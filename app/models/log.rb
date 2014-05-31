class Log < ActiveRecord::Base
  
  attr_accessible :user_id, :level, :remote_ip, :referer, :request, :method, :user_agent, :message, :controller, :action
  
  belongs_to :user
  
  def self.log(attributes)
    log = Log.new( attributes )
    log.save
    unless log.errors.empty?
      logger.error "log.save failed. attributes: " + attributes.to_s
    end
  end
  
end