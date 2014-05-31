class CoursesController < ApplicationController
  
  # this method is needed because otherwise, the auto_complete function in edit causes
  # this error: ActionController::InvalidAuthenticityToken
  # which happens because of a missing rails "authenticity_token" - this fix
  # feels a bit hackish, but works for now.
  protect_from_forgery :only => [:create, :delete, :update]
  before_filter :authorize_admin_editor_only, :only => [:new]
  before_filter :login_check, :except => [:completed]
  
  
  respond_to:json
  
  
  
  def load_path
    super
    @path_action_controller = :courses
  end
  
  def load_course_list
    @list_options = session[:list_options]
    @list_options[:sort] = params[:sort] unless params[:sort].nil?
    @list_options[:search_text] = params[:search_text] unless params[:search_text].nil?
    @list_options[:page] = params[:page] unless params[:page].nil?
    session[:list_options] = @list_options
    
    per_page = 10

    unless @list_options[:search_text].nil? or @list_options[:search_text].empty?
      @courses = Course.paginate_search(@list_options[:search_text], per_page, @list_options[:page], @list_options[:sort])
      
    else
      @courses = Course.paginate(:per_page => per_page, :page => @list_options[:page], :order => @list_options[:sort])
    end
    
  end
  
  def index
    load_course_list if logged_in?
    
    
    
    respond_to do |format|
      format.html
      format.js
      # format.xml {render :xml => @all_courses.to_xml(:only => [:id], :include => {:course_proficiencies =>{:only => [:proficiency_direction]} )}
      format.xml {
        @courses = Course.all
        render :xml => @courses.to_xml( :dasherize => false, :only => [:id,:title,:prefix,:number,:description],  
                :include => {:course_proficiencies => {:only => [:proficiency_direction,:slot], :include => {:proficiency => {:only => [:id, :name, :level]}}}})
        }
        
	format.json {
       @courses = Course.all
       respond_with(@courses)
     }
      
    end
  end
  
  def build_incoming_proficiency_options
    incoming_list = Proficiency.search_fullnames_for_auto_complete( '', @course.level, 'Incoming' )
    @incoming_proficiency_options = []
    unless incoming_list.nil?
      incoming_list.each do |prof|
        @incoming_proficiency_options.push([prof,prof])
      end
    end
  end
  
  def build_outgoing_proficiency_options
    outgoing_list = Proficiency.search_fullnames_for_auto_complete( '', @course.level, 'Outgoing' )
    @outgoing_proficiency_options = []
    unless outgoing_list.nil?
      outgoing_list.each do |prof|
        @outgoing_proficiency_options.push([prof,prof])
      end
    end
  end
  
  def build_semester_options
    semesters_list = Semester.search_fullnames_for_auto_complete('')
    @semesters_options = []
    unless semesters_list.nil?
      semesters_list.each do |a_semester|
        @semesters_options.push([a_semester,a_semester])
      end
    end
  end

  def show
    @course = Course.find(params[:id])
    @reviews = @course.reviews
    @r = @course.recommendation
    build_incoming_proficiency_options
    build_outgoing_proficiency_options
    build_semester_options
    
    if request.xml_http_request?
      render :partial => "show_course", :layout => false
    end
  end

  def new
    @title = "Create a new Course"
    @course = Course.new
    flash[:notice] = "Please enter details for the new course, then click the CREATE button."
  end

  def create
    unless params[:course].nil?
      semester_hash = params["start_semester"]
      params[:course].store("anticipated_start_date(2i)", Semester.start_month_for_semester(semester_hash["name"]))
      params[:course].store("anticipated_start_date(3i)", Semester.start_day_for_semester(semester_hash["name"]))
      @course = Course.new(params[:course])
    else
      flash[:notice] = "Please enter details for the new course."
    end
    if @course.save
      flash[:notice] = "New course \"#{@course.title}\" has been created."
      redirect_to course_path(@course)
    else
      render :action => 'new'
    end
  end

  def edit
    @course = Course.find(params[:id])
    redirect_to course_path(@course) unless current_user.can_edit_course?(@course)
    
    @title = "Edit Course Details"
    
    @start_semester = Semester.new({ :name => Semester.semester_for_month(@course.anticipated_start_date.month()), 
                                     :year => @course.anticipated_start_date.year() })
  end

  def update
    @course = Course.find(params[:id])
    
    semester_hash = params["start_semester"]
    params[:course].store("anticipated_start_date(2i)", Semester.start_month_for_semester(semester_hash["name"]))
    params[:course].store("anticipated_start_date(3i)", Semester.start_day_for_semester(semester_hash["name"]))
    
    if @course.update_attributes(params[:course])
      flash[:notice] = "The course #{@course.title} was successfully updated."
      redirect_to course_path(@course)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @course = Course.find(params[:id])
    flash[:notice] = "The course #{@course.title} was successfully deleted."
    @course.destroy
    redirect_to courses_path
  end
  
  def add_incoming_proficiency
    @course = Course.find(params[:id])
    build_incoming_proficiency_options
    @proficiency = Proficiency.search_by_fullname(params[:in_proficiency][:fullname])
    unless @proficiency.nil?
      #if @course.proficiency_exists?(@proficiency)
      #  flash[:notice] = "This proficiency has already been added to the list."
      if not @course.can_add_in_proficiency?(@proficiency)
        flash[:notice] = "This proficiency cannot be added as there is a level mismatch with the course."
      elsif @course.reached_in_proficiency_limit_for_slot?(params[:slot])
        flash[:notice] = "Incoming Proficiency Limit exceeded for slot. Maximum of 5 optional incoming proficiencies are allowed per slot."
      else
        course_proficiency = CourseProficiency.create_course_proficiency("Incoming", @course.id, @proficiency.id, params[:slot])
        flash[:notice] = "Added incoming proficiency #{@proficiency.fullname} to #{@course.title}"
      end
    else
      flash[:notice] = "Unable to find proficiency."
    end

    respond_to do |format|
      format.js { render :template => 'courses/update_incoming_proficiency.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def add_outgoing_proficiency
    @course = Course.find(params[:id])
    @proficiency = Proficiency.search_by_fullname(params[:out_proficiency][:fullname])
    
    unless @proficiency.nil?
      if @course.proficiency_exists?(@proficiency)
        flash[:notice] = "#{@proficiency.fullname} is already in the list."
      elsif not @course.can_add_out_proficiency?(@proficiency)
        flash[:notice] = "This proficiency cannot be added because the level doesn't match with the course."
      elsif @course.reached_out_proficiency_limit?
        logger.debug "Outgoing Proficiency Limit exceeded. Maximum of 5 outgoing proficiencies are allowed."
        flash[:notice] = "Only 5 outgoing proficiencies are allowed."
      else
        flash[:notice] = "Added outgoing proficiency #{@proficiency.fullname} to #{@course.title}"
        course_proficiency = CourseProficiency.create_course_proficiency("Outgoing", @course.id, @proficiency.id, nil)
      end
    else
      flash[:notice] = "Unable to find proficiency."
    end
   
    respond_to do |format|
      format.js { render :template => 'courses/update_outgoing_proficiency.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def lower_incoming_proficiency_level
    @course = Course.find(params[:id])
    @course_proficiency = CourseProficiency.find(params[:course_proficiency_id])
    @proficiency = @course_proficiency.proficiency
    
    new_level = @proficiency.level - 100
    new_proficiency = Proficiency.find(:first,:conditions => "name='#{@proficiency.name}' and level='#{new_level}'")
    @course_proficiency.set_proficiency(new_proficiency)
    
    respond_to do |format|
      format.js { render :template => 'courses/update_incoming_proficiency.js.erb' }
    end
  end
  
  def raise_incoming_proficiency_level
    @course = Course.find(params[:id])
    @course_proficiency = CourseProficiency.find(params[:course_proficiency_id])
    @proficiency = @course_proficiency.proficiency
    
    new_level = @proficiency.level + 100
    new_proficiency = Proficiency.find(:first,:conditions => "name='#{@proficiency.name}' and level='#{new_level}'")
    @course_proficiency.set_proficiency(new_proficiency)
    
    respond_to do |format|
      format.js { render :template => 'courses/update_incoming_proficiency.js.erb' }
    end
  end
  
  
  def destroy_incoming_proficiency
    @course = Course.find(params[:id])
    @cp = CourseProficiency.find(params[:course_proficiency_id])
    @cp.destroy
    flash[:notice] = "Removed incoming proficiency #{@cp.proficiency.fullname} from #{@course.title}, slot #{@cp.slot}"
    respond_to do |format|
      format.js { render :template => 'courses/update_incoming_proficiency.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def destroy_outgoing_proficiency
    @course = Course.find(params[:id])
    @cp = CourseProficiency.find(params[:course_proficiency_id])
    @cp.destroy
    flash[:notice] = "Removed outgoing proficiency #{@cp.proficiency.fullname} from #{@course.title}"
    respond_to do |format|
      format.js { render :template => 'courses/update_outgoing_proficiency.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def update_special_proficiencies
    logger.debug "update_special_proficiencies"
  end
  
  def add_class
    @course = Course.find(params[:id])
    
    @semester = Semester.search_by_fullname(params[:semester][:fullname])
    unless @semester.nil?
      existing_class = Instance.find(:first, :conditions => "course_id='#{@course.id}' and semester_id='#{@semester.id}'" )
      if existing_class.nil?
        Instance.create_instance(params[:instance], @course.id, @semester.id)
        flash[:notice] = "Added course offering for #{@semester.name} #{@semester.year}"
      else
        flash[:notice] = "The course is already offered during #{@semester.name} #{@semester.year}"
      end
    else
      flash[:notice] = "Unable to find semester."
    end
    respond_to do |format|
      format.js { render :template => 'courses/update_class_list.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def destroy_class
    @course = Course.find(params[:id])
    @class = Instance.find(params[:instance_id])
    @class.destroy
    respond_to do |format|
      format.js { render :template => 'courses/update_class_list.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def add_review
    @course = Course.find(params[:id])
    unless params[:review].nil?
      params[:review].store("student_id", current_user.id)
      puts params[:review]
      @review = @course.reviews.create(params[:review])
    else
      flash[:notice] = "Please enter the text for the review."
    end
    @reviews = @course.reviews
     if request.xml_http_request?
        render :partial => "reviews_sub", :layout => false
      end
  end
  
  def edit_review
    show_review_edit = true
    @course = Course.find(params[:id])
    @review = @course.reviews.find(params[:review_id])
    if params[:review]
      @review.update_attributes(params[:review])
      flash[:notice] = "Your review was successfully updated."
      show_review_edit = false
    else
      flash[:notice] = "There was some error updating your review. Please try again."
    end
    @reviews = @course.reviews
    if request.xml_http_request?
      render :partial => "reviews_sub", :layout => false, :locals => {:show_review_edit => show_review_edit}
    end
  end
  
  def add_recommendation
    @course = Course.find(params[:id])
    unless params[:recommendation].nil?
      @recommendation = @course.create_recommendation(params[:recommendation])
    else
      flash[:notice] = "Please enter the text for the recommendation."
    end
    @r = @course.recommendation
     if request.xml_http_request?
        render :partial => "recommendations_sub", :layout => false
      end
  end
  
  def edit_recommendation
    show_reco_edit = true
    @course = Course.find(params[:id])
    if params[:recommendation]
      @course.recommendation.update_attributes(params[:recommendation])
      flash[:notice] = "The recommendation was successfully updated."
      show_reco_edit = false
    else
      flash[:notice] = "There was some error updating the recommendation. Please try again."
    end
    @r = @course.recommendation
    if request.xml_http_request?
      render :partial => "recommendations_sub", :layout => false, :locals => {:show_reco_edit => show_reco_edit}
    end
  end
  
  def completed
    per_page = 10
    @courses = current_user.courses.paginate(:per_page => per_page, :page => params[:page], :order => "prefix, number")
    
    respond_to do |format|
      format.html
      format.js { render :partial => "course_list", :layout => false }
      format.xml { 
        @courses = current_user.courses
        render :xml => @courses.to_xml( :only => [:id, :title, :prefix, :number, :description],
                                                   :include => {:course_proficiencies => {:only => [:proficiency_direction, :slot], 
                                                                                          :include => {:proficiency => {:only => [:id, :name, :level] }}}} ) 
        }
    end
  end
  
  def add_completed_course
    @course = Course.find(params[:id])
    @user_course = current_user.user_courses.new(:course_id => @course.id)
    unless @user_course.save
      flash[:notice] = "There was an error adding #{@course.title} to the list of completed courses. Please try again."
    else
      flash[:notice] = "#{@course.shortname} was added to your list of completed courses."
      @current_path.reload
      current_user.reload
    end
    
    request_parts = request.referer.split('/')
    if request_parts.last == 'courses'
      @render_course_list = true
      load_course_list
    else
      @render_course_list = false
    end
    
    respond_to do |format|
      format.js { render :template => 'courses/add_completed_course.js.rjs' }
    end
  end
    
  def remove_course_from_completed_courses
    @course = Course.find(params[:course_id])
    @user_course = current_user.user_courses.find_by_course_id(@course.id)
    unless @user_course.destroy
      flash[:notice] = "There was an error removing #{@course.title} from the list of completed courses. Please try again."
    else
      flash[:notice] = "Removed #{@course.shortname} from your completed courses list."
      @current_path.reload
      current_user.reload
    end
    
    request_parts = request.referer.split('/')
    if request_parts.last == 'courses'
      @render_course_list = true
      load_course_list
    else
      @render_course_list = false
    end
    
    respond_to do |format|
      format.js { render :template => 'courses/update_path.js.erb' }
    end
    flash.discard(:notice)
  end
  
  # find the path instance of this course in current path (ie the class) and delete it.
  def destroy_instance_for_course( instance_id )
    path_instance = PathInstance.find(:first, :conditions => "instance_id='#{instance_id}' AND path_id='#{@current_path.id}'")
    @course = path_instance.instance.course
    path_instance.destroy
    flash[:notice] = "Removed #{@course.shortname} from path."
    
    request_parts = request.referer.split('/')
    if request_parts.last == 'courses'
      # nothing?
    else
      @render_course_list = false
    end
    
    @current_path.reload
    load_path
    
    flash[:notice] = "Removed #{@course.shortname} from path."
    respond_to do |format|
      format.js { render :template => 'courses/update_path.js.erb' }
    end
    flash.discard(:notice)
  end
  
  # user clicked link in the path section, to remove class from path
  def delete_class_from_path
    destroy_instance_for_course(params[:instance_id])
  end
  
  def remove_history_course( acourse )
    pei = @current_path.path_external_instances.find(:first, :conditions => {:external_instance_id => acourse.id})
    ec = pei.external_instance.external_course
    pei.destroy
    
    flash[:notice] = "Removed History and Theory course #{ec.shortname} from path."
    
    @current_path.reload
    current_user.reload
    load_path
    
    respond_to do |format|
      format.js { render :template => 'courses/update_path.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def remove_history_course_from_path
    acourse = ExternalInstance.find(params[:external_instance_id])
    remove_history_course(acourse) unless acourse.nil?
  end
  
  
  def authorize_admin_editor_only
    unless current_user.can_add_course?
      flash[:notice] = "Only administrator users can view the resource #{params[:controller]}/#{params[:action]}."
      redirect_to :controller => 'courses', :action => 'index'
    end
    true
  end
  
  
  
end

