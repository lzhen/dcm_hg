require 'digest/sha1'
require 'socket'
require 'rubygems'
require 'net/ldap'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  set_inheritance_column 'user_type'
  
  has_many :paths, :foreign_key => "student_id", :dependent => :destroy
  #has_many :recommendations
  has_many :reviews, :foreign_key => "student_id"
  
  has_many :user_courses, :dependent => :destroy
  has_many :courses, :through => :user_courses
  has_many :rights, :dependent => :destroy
  
  before_save :encrypt_password
  
  #validates_presence_of :user_name, :first_name, :last_name, :user_type
  
  USER_TYPES = [
    ["Faculty","faculty"],
    ["Student","student"],
    ["Staff","staff"],
    ].freeze

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :middle_name, :last_name, :name, :password, :password_confirmation, :current_path, :degree

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  #
  # connect to ASU LDAP, submit an ASURITE username, return a hash of information about a user
  def self.ldap_user_info( asuriteid )
    ldap = Net::LDAP.new( 
      :host => 'ds.asu.edu',
      :port => 389,
      :auth => {
      :method => :simple,
      :username => 'uid=digitalculture_app,ou=ReadOnly,o=asu.edu',
      :password => '9A4=u?u%2WU_e7'
      }
      )
    
    results = nil
    
    if ldap.bind
      logger.debug 'successful bind'

      filter = Net::LDAP::Filter.eq( "asuriteid", asuriteid )
      treebase = "ou=People,o=asu.edu"
      
      results = {}

      ldap.search( :base => treebase, :filter => filter ) do |entry|
        logger.debug "DN: #{entry.dn}"
        entry.each do |attribute, values|
          results[attribute.to_s] = values.join(',')
          logger.debug "   #{attribute}:"
          values.each do |value|
            logger.debug "      --->#{value}"
          end
        end
      end
    else
      logger.error 'ldap bind failed'
    end
    
    results
  end
  
 
  def name
    if first_name.nil? and last_name.nil?
      return login
    elsif first_name.nil?
      return last_name
    elsif last_name.nil?
      return first_name
    end
    first_name + " " + last_name
  end
  
  def self.random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def dcm_encrypt(password)
    self.class.encrypt(password, salt)
  end
  
  def find_right_for_course?( prefix )
    for right in rights
      return true if (right.prefix == prefix) and (right.name == 'Editor')
    end
    false
  end
  
  def find_any_course_rights?
    for right in rights
      return true if right.name == 'Editor'
    end
    false
  end
  
  def can_edit_course?( course )
    is_admin or find_right_for_course?( course.prefix )
  end
  
  def can_add_course?
    is_admin or find_any_course_rights?
  end
  
  def can_edit_proficiency?
    is_admin
  end
  
  def can_add_proficiency?
    is_admin
  end
  
  def can_add_user?
    is_admin
  end
  
  def is_student?
    self.user_type == "Student"
  end
    
  def has_path?
    return false if current_path.nil?
    true
  end
  
  def can_submit_review?(course)
    if reviews.exists?(:course_id => course)
      return false
    elsif courses.exists?(course)
      return true
    else
      #check if course exists in any path
      result = false
      paths.each do |p|
        if p.instances.exists?(:course_id => course)
          result = true
          break
        end
      end
      return result
    end
  end
  
  def set_current_path_nil
    update_attribute(:current_path,nil)
  end
  
  def is_course_in_completed_list? ( course )
    self.user_courses.exists?(:course_id => course)
  end
  
  #def can_add_previous_course? ( course )
  #  not self.user_courses.exists?(:course_id => course)
  #end
  
  #proficiencies collected from completed courses
  def collected_proficiencies
    list = []
    self.courses.each do |c|
      c.outgoing_proficiencies.each do |p|
        plist = Proficiency.find(:all, :conditions => ["name = ? and level <= ?", p.name, p.level])
        list << plist
      end
    end
    list.flatten!.uniq! unless list.empty?
    return list
  end
  
  def User.search( per_page, page, search_text )
    search = ''
    search += sanitize_sql_array(['users.last_name like ? or users.first_name like ?', "%#{search_text}%","%#{search_text}%"]) unless search_text.empty?
    User.paginate(:per_page => per_page, :page => page, :order => 'last_name, first_name', :conditions => search)
  end
  
  def credit_hours_in_completed_courses
    #
    # TODO: this is hackish! there should be formal way to identify the categories same as
    # "Major Map" documentation from Erica identifies them. (Should be part of database, not code)
    excluded_courses = ['ENG 102', 'ENG 105', 'ENG 108', 'MAT 117', 'MAT 170', 'MAT 210']
    
    credit_hours = 0
    courses.each do |c|
      unless excluded_courses.include?(c.shortname)
        credit_hours += c.credit_hours
      end
    end
    credit_hours
  end
  
  protected
  
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = dcm_encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end

  
end
