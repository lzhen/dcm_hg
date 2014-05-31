class FrontController < ApplicationController
  
  layout "front"
  before_filter :login_check, :except => [:index, :about, :degrees, :proficiencies, :contacts, :courses, :facilities, :faculty, :course_info, :forms]
  
  def handle_asurite_authenticator_login
    logger.info('handle_asurite_authenticator')
    sd = TCPSocket.open("webauth.asu.edu",3001)
    
    #
    # This version that uses HTTP_X_FORWARDED_FOR is needed when deployed using
    # mongrel, because of the balancer proxy forwarding.
    #sd.puts params[:authenticator] + ":" + request.env["HTTP_X_FORWARDED_FOR"]
    
    # This version works when deployed with Passenger. (no proxy)
    sd.puts params[:authenticator] + ":" + request.env['REMOTE_ADDR']
    
    weblogin_reply = sd.gets
    
    logger.info "webauth reply: " + weblogin_reply
    
    reply_split = weblogin_reply.split(':')
    if reply_split[0] == "0"
      #
      # successful asurite login
      #
      principal_type = reply_split[1].split('@')
      asurite_username = principal_type[0]
      user = User.find_by_login(asurite_username)
      if user.nil?
        #
        # this must be the user's first time logining in, so we must create a user row for them
        #
        logger.info "need to create a user for this asurite"
        create_user( asurite_username )
        
      else
        
        logger.info "found user " + user.name
        
      end
      
      self.current_user = user
      log_debug( "Successful login by user: #{user.login}" )
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      setup_list_options
      if user.class == Student
        redirect_back_or_default('/map')
      else
        redirect_back_or_default('/courses')
      end
      
    elsif reply_split[0] == "1"
      # credential expired - should redirect to weblogin
      redirect_to "https://weblogin.asu.edu/cgi-bin/login?callapp=http://digitalculture.asu.edu"
    elsif reply_split[0] == "2"
      # client ip address doesn't match verify address
      log_debug( "Login error 2, client ip address doesn't match verify address" )
      redirect_to :controller => 'sessions', :action => 'login_error'
    elsif reply_split[0] == "3"
      # server ip address doesn't match application address
      log_debug( "Login error 3, server ip address doesn't match application address" )
      redirect_to :controller => 'sessions', :action => 'login_error'
    elsif reply_split[0] == "7"
      # authentication was invalid
      log_debug( "Login error 7, authentication was invalid" )
      redirect_to :controller => 'sessions', :action => 'login_error'
    else
      # anything is undefined ??? unknown error
      log_debug( "Login error unknown, unknown error" )
      redirect_to :controller => 'sessions', :action => 'login_error'
    end
  end
  
  def index
    if params[:authenticator].nil?
      @page_title = 'Digital Culture | ASU Herberger Institute for Design and the Arts'
    else
      handle_asurite_authenticator_login
    end
  end
  
  def about
    @page_title = 'About | Digital Culture | ASU Herberger Institute for Design and the Arts'
  end

  def degrees
    @page_title = 'Degrees | Education | Digital Culture | ASU Herberger Institute for Design and the Arts'
    
  end

  def proficiencies
    @page_title = 'Proficiencies | Education | Digital Culture | ASU Herberger Institute for Design and the Arts'
    
  end

  def contacts
    @page_title = 'Contacts | Digital Culture | ASU Herberger Institute for Design and the Arts'
 
  end

  def courses
    @page_title = 'Courses | Education | Digital Culture | ASU Herberger Institute for Design and the Arts'
    
    # TODO: fix this! 
    # This is gonna be very hackish, but will work for now. Please revise this to work for the general case moving forward.
    #
    
    # In this page, we will show the current, and next semester of scheduled courses.
    #
    
    @current_semester = Semester.where("name = 'Fall' and year = '2010'").first
    @current_courses = @current_semester.instances.collect { |i| i.course unless i.course.prefix == 'MAT' or i.course.prefix == 'ENG' }
    @current_courses.compact!
    @current_courses.sort! {|x,y| x.prefix <=> y.prefix }
    
    @next_semester = Semester.where("name = 'Spring' and year = '2011'").first
    @next_courses = @next_semester.instances.collect { |i| i.course unless i.course.prefix == 'MAT' or i.course.prefix == 'ENG' }
    @next_courses.compact!
    @next_courses.sort! {|x,y| x.prefix <=> y.prefix }
  end
  
  def faculty
    @page_title = 'Faculty | Education | Digital Culture | ASU Herberger Institute for Design and the Arts'
  end

  def facilities
    @page_title = 'Facilities | Digital Culture | ASU Herberger Institute for Design and the Arts'
  end
  
  def course_info
    @course = Course.find(params[:id])
    respond_to do |format|
       format.js
    end
  end
  
  def issue
    @page_title = 'Issue Request | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @issue = Issue.new
  end
  
  def submit_issue
    @page_title = 'Issue Sent | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @issue = Issue.new(params[:issue])
    @issue.user_id = current_user.id
    if @issue.save
      UserMailer.send_request(@issue).deliver
    else
      render :action => 'issue'
    end
  end
  
  def forms
    @page_title = 'Forms | Digital Culture | ASU Herberger Institute for Design and the Arts'
  end
  
  def open_house
    @page_title = 'Open House | Digital Culture | ASU Herberger Institute for Design and the Arts'
  end

end
