class Faculty < User
  
  
  
  def self.create_user( user_attributes )
    
    randomized_password = User.random_password
    attributes = {
      :email => (user_attributes[:login] + '@asu.edu'),
      :password => randomized_password, 
      :password_confirmation => randomized_password,
    }.merge! user_attributes
    
    user = Faculty.new(attributes)
    logger.error "user is nil!" if user.nil?
    
    # these assignments are here becasue they cannot be mass assigned
    user.is_admin = false
    
    if user.save!
      user.reload
      return user
    else
      logger.error "record not saved"
    end
    nil
  end
  
  
  
end