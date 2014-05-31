require 'socket'
require 'rubygems'
require 'net/ldap'

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  layout "sessions"
  
  before_filter :login_check, :except => [:new, :create, :bye, :login_error, :about]
  
  
  
  def about
    if params[:authenticator].nil?
      render :layout => false
    else
      handle_asurite_authenticator_login
    end
  end
  
  def show
  	puts "Hello"
  end
  
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
  
  # render new.rhtml
  def new
    logger.info('>>> sessions.new <<<')
    if RAILS_ENV == 'production'
      #
      # in production environment, use ASURITE to login
      #
      if params[:authenticator].nil?
        #
        # if :authenticator isn't in the URL, then redirect to weblogin for ASURITE login
        #
        redirect_to "https://weblogin.asu.edu/cgi-bin/login?callapp=http://digitalculture.asu.edu"
      else
        #
        # :authenticator is in the URL, so we check it against webauth to get user login
        #
        
        handle_asurite_authenticator_login
      
      end
    else
      @page_title = 'Digital Culture - Login'
    end
  end

  def create
    logger.info(">>> sessions.create <<<")
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    logger.info("Login: #{params[:login]}")
    logger.info("Password: #{params[:password]}")
    if user
      logger.info(">>> successful authentication for user #{user.login} (#{user.name}) <<<")
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      log_debug( "Successful login by user: #{user.login}" )
      setup_list_options
      session[:new_login] = true
      unless session[:return_to].nil?
        redirect_to session[:return_to]
      else
        if user.class == Student
          redirect_back_or_default('/map')
        else
          redirect_back_or_default('/courses')
        end
      end
    else
      logger.info('>>> authenticate failed <<<')
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    log_debug( "Logout user: #{current_user.login}" )
    if RAILS_ENV == 'production'
      redirect_to "https://weblogin.asu.edu/cgi-bin/login?onLogoutURL=http://herbergerinstitute.asu.edu/"
    else
      logout_killing_session!
      redirect_back_or_default('/')
    end
  end
  
  def bye
  end
  
  def login_error
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
