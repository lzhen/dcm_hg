class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper :all # include all helpers, all the time

  include AuthenticatedSystem
  
  $SHOW_REVIEWS = false


  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  before_filter :login_check
  before_filter :log_request
  before_filter :load_controller_list
  before_filter :load_path

  def login_check
    @page_title = 'Digital Culture'
    unless authorized?
      store_location
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end

  def log_request
    logger.debug "request: " + request.fullpath
    logger.debug "method: " + request.method().to_s
    logger.debug "referer: " + request.referer().to_s
    logger.debug "ip: " + request.remote_ip()
    logger.debug "user agent: " + request.env['HTTP_USER_AGENT']

    log_debug('-')
  end

  def log_debug( message )
    Log.log( { 
      :action => params[:action],
      :controller => params[:controller],
      :level => 0,  
      :method => request.method().to_s,
      :message => message,
      :remote_ip => request.remote_ip(),
      :referer => request.referer().to_s,
      :request => request.fullpath,
      :user_agent => request.env['HTTP_USER_AGENT'],
      :user_id => current_user.nil? ? 0 : current_user.id
      } )
  end

  def load_controller_list
    @controllers = [
      { :path => "/", :title => "Digital Culture home page", :ui_name => "Home", :name => "home"},
      { :path => "/courses", :title => "A list of all courses", :ui_name => "Courses", :name => "courses"},
      { :path => "/proficiencies", :title => "A list of generalized proficiences", :ui_name => "Proficiencies", :name => "proficiencies"},
      { :path => "/paths", :title => "A list of my paths", :ui_name => "Paths", :name => "paths"},
      { :path => "/map", :title => "Interactive Course Map", :ui_name => "Map", :name => "map" },
      { :path => "/compass", :title => "Interactive Compass", :ui_name => "Compass", :name => "compass"},
      { :path => "/help", :title => "Helpful information about this web application", :ui_name => "Help", :name => "help" }
      ]
    unless current_user.nil?
      if current_user.is_admin
        @controllers.push(
          { :path => "/users", :title => "A list of users", :ui_name => "Users", :name => "users" } )
      end
    end
  end

  def load_path
    @current_path = nil
    @path_classes = nil
    @path_action_controller = :paths
    return if current_user.nil?
    unless current_user.current_path.nil?
      if current_user.paths.exists?(current_user.current_path)
        @current_path = current_user.paths.find(current_user.current_path)
        @path_classes = @current_path.instances
        @path_semesters = Hash.new(1)
        @path_classes.each do |c|
          if @path_semesters.has_key?(c.semester_id)
            @path_semesters[c.semester_id] << c
          else
            @path_semesters[c.semester_id] = [c]
          end
        end
        @current_path.external_instances.each do |c|
          if @path_semesters.has_key?(c.semester_id)
            @path_semesters[c.semester_id] << c
          else
            @path_semesters[c.semester_id] = [c]
          end
        end
        @path_semesters_sorted = @path_semesters.sort
      else
        # the value in current_path is invalid, so lets set it to nil
        current_user.set_current_path_nil
      end
    end
  end

  # this is super hackish!!! fix this please!!!
  def setup_list_options
    session[:list_options] = {
      :search_text => '',
      :sort => 'prefix, number',
      :page => 1
    }
    session[:map_options] = {
      100 => { :page => 1 },
      200 => { :page => 1 },
      300 => { :page => 1 },
      400 => { :page => 1 },
      :selected_course => nil,
      :show_proficiency => nil
    }
  end

  def create_user_from_ldap( asuriteid, user_info )
    attributes = { 
      :login => asuriteid, 
      :first_name => user_info['givenname'],
      :last_name => user_info['sn'],
      :middle_name => user_info['middlename'],
      :email => user_info['mail'],
      :title => user_info['title'],
      :department => user_info['department']
    }
    logger.debug 'primaryaffiliation: ' + user_info['primaryaffiliation']
    logger.debug 'attributes: '
    logger.debug attributes

    if user_info['primaryaffiliation'] == 'Employee'
      if user_info['affiliatedesc'] == 'Faculty'
        user = Faculty.create_user( attributes )
        log_debug( "Create Faculty user: #{user.login}" )
      else
        user = Staff.create_user( attributes )
        log_debug( "Create Staff user: #{user.login}" )
      end
    elsif user_info['primaryaffiliation'] == 'Student'
      attributes[:degree] = user_info['major']
      user = Student.create_user( attributes )
      log_debug( "Create Student user: #{user.login}" )
    else
      user = Student.create_user( attributes )
      log_debug( "Create Student user (fallback case): #{user.login}" )
    end

    user
  end

  #
  # this is a fallback for the case where ldap fails
  # should we instead just error out and fail if we can't get ldap info????
  #
  def create_user_from_webauth_only( asuriteid, user_type )
    if user_type == 'FACULTY'
      user = Faculty.create_user( { :login => asuriteid } )
    elsif user_type == 'STUDENT'
      user = Student.create_user( { :login => asuriteid } )
    elsif user_type == 'STAFF'
      user = Staff.create_user( { :login => asuriteid } )
    else
      user = Student.create_user( { :login => asuriteid } )
    end
    log_debug( "Create user without LDAP info: #{user.login}, user_type is #{user_type}" )
    user
  end

  def create_user( asurite_username )
    user_info = User.ldap_user_info( asurite_username )

    if user_info.nil?
      #
      # this should not happen. if user_info is nil, then ldap did not respond to us,
      # or there was no ldap info for the asurite username? this is a fallback.
      #
      logger.warn "no ldap info? create user from webauth info only"
      user = create_user_from_webauth_only( asurite_username, reply_split[3] )
    else
      user = create_user_from_ldap( asurite_username, user_info )
    end

    Path.create_path( user, "My Path" )
  end
end
