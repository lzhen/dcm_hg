class UsersController < ApplicationController

  before_filter :authorize_admin_only, :except => [:completed]
  before_filter :login_check, :except => [:completed]
  
  
  # render new.rhtml
  def new    
    @user = User.new
  end
 
  def create
    user_params = params[:user]
    if user_params.nil? or user_params[:login].nil? or user_params[:login].empty?
      flash[:notice] = "Please enter an asurite"
      render :action => 'new'
    end
    
    @user = User.find_by_login(user_params[:login])
    if @user.nil?
      create_user(user_params[:login])
      @user = User.find_by_login(user_params[:login])
      if @user.nil?
        flash[:notice] = "There was a error creating user #{user_params[:login]}. Please enter an asurite"
        render :action => 'new'
      end
      flash[:notice] = "Created user #{@user.login}/#{@user.name}."
    else
      flash[:notice] = "User already exists #{@user.login}/#{@user.name}."
    end
    
    redirect_to edit_user_path(@user)
  end
  
  def index
    @title = "Users"
    
    if params[:search_name].nil?
      @users = User.paginate(:per_page => 20, :page => params[:page], :order => 'last_name, first_name')
      @search = {}
      @search[:search_name] = ''
    else
      @users = User.search(50, params[:page], params[:search_name])
    end
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def show
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "User #{@user.name} was successfully updated."
      redirect_to edit_user_path(@user)
    else
      render :action => 'edit'
    end
  end
  
  def add_right
    @user = User.find(params[:id])
    #right_params = params[:right]
    new_right = Right.create(:user_id => @user.id, :prefix => params[:prefix], :name => 'Editor')
    
    respond_to do |format|
      format.js
    end
  end
  
  def destroy_right
    @user = User.find(params[:id])
    right = Right.find(params[:right_id])
    right.destroy
    
    respond_to do |format|
      format.js
    end
  end
  
  def authorize_admin_only
    unless current_user.is_admin
      flash[:notice] = "Only administrator users can view the resource #{params[:controller]}/#{params[:action]}."
      redirect_to :controller => 'courses', :action => 'index'
    end
    true
  end
  
  def completed
    @user = User.find(params[:id])
    logger.debug(@user.name)
    respond_to do |format|
      format.html
      format.js
      format.xml { 
        @courses = @user.courses
        
        render :xml => @courses.to_xml( :only => [:id, :title, :prefix, :number, :description],
                                                   :include => {:course_proficiencies => {:only => [:proficiency_direction, :slot], 
                                                                                          :include => {:proficiency => {:only => [:id, :name, :level] }}}} ) 
        
        }
    end
  end
  
end
