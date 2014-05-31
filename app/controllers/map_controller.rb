class MapController < ApplicationController
  
  before_filter :load_options
  before_filter :setup_ui
  before_filter :setup_login_message
  
  def setup_ui
    @barmsg = ''
    @refresh_course_strips = false
    @render_map = true
    @refresh_course_strips = false
    @render_history_list = false
    @render_detail = true
    @operation = 0
    @course = nil
    @now = DateTime.now
  end
  
  def load_path
    super
    @path_action_controller = :map
  end
  
  def setup_login_message
    @show_login_message = false
    if session[:new_login]
      @show_login_message = true
      session[:new_login] = false
    end
  end
  
  def load_options
    @map_options = session[:map_options]
    if @map_options[:selected_course].nil?
      @selected_course = nil
    else
      @selected_course = Course.find(@map_options[:selected_course])
    end
    if @map_options[:show_proficiency].nil?
      @show_proficiency = nil
    else
      @show_proficiency = Proficiency.find(@map_options[:show_proficiency])
    end
  end
  
  def load_course_strips(prof = nil)
    @refresh_course_strips = true
    @courses_100 = MapStrip.new(100,@map_options[100][:page],prof)
    @courses_200 = MapStrip.new(200,@map_options[200][:page],prof)
    @courses_300 = MapStrip.new(300,@map_options[300][:page],prof)
    @courses_400 = MapStrip.new(400,@map_options[400][:page],prof)
  end
  
  def index
    if @current_path.nil?
      flash[:notice] = "You need to set or create a current path before you can use the map feature."
      redirect_to :controller => 'paths', :action => 'index'
      return
    # else
    #  load_course_strips(@show_proficiency)
    #  prepare_detail_info(@selected_course) unless @selected_course.nil?
    end
    
    #@all_course_proficiencies = CourseProficiency.all
    #@all_courses = Course.all
    
    # respond_to do |format|
   #   format.html
      # format.xml {render :xml => @all_courses.to_xml(:only => [:id], :include => {:proficiencies => {:only => [:id, :level, :name]}})
    # end
     
  end
  
  def build_history_course_options
    external_course_list = ExternalCourse.find(:all)
    @history_course_options = []
    unless external_course_list.nil?
      external_course_list.each do |c|
        @history_course_options.push([c.fullname,c.id])
      end
    end
  end
  
  def build_semester_options
    semesters_list = Semester.search_fullnames_for_auto_complete('')
    @semester_options = []
    unless semesters_list.nil?
      semesters_list.each do |a_semester|
        @semester_options.push([a_semester,a_semester])
      end
    end
  end
  
  def history_studies
    build_history_course_options
    build_semester_options
  end
  
  def add_history_course
    external_course = ExternalCourse.find(params[:external_course][:id])
    semester_for_course = Semester.search_by_fullname(params[:semester][:fullname])
    
    external_instance = ExternalInstance.find(:first, :conditions => { :external_course_id => external_course.id, :semester_id => semester_for_course.id})
    if external_instance.nil?
      external_instance = ExternalInstance.create(:external_course_id => external_course.id, :semester_id => semester_for_course.id)
    end
    
    pei = PathExternalInstance.create(:path_id => @current_path.id, :external_instance_id => external_instance.id)
    flash[:notice] = "History and Theory course #{external_course.shortname} was added to your path."
    
    @render_history_list = true
    @render_detail = false
    
    @operation = 5
    @course = external_course
    
    @current_path.reload
    current_user.reload
    load_path
    respond_to do |format|
       format.js { render :template => 'map/update_map.js.erb' }
    end
    flash.discard(:notice)
  end
  
  
  def prepare_detail_info(course)
    @is_course_in_path = @current_path.course_exists?(course)
    @profs_in_path = @current_path.list_of_proficiencies + current_user.collected_proficiencies
    @incoming_slots = []
    unless course.nil?
      1.upto 5 do |j|
        unless course.incoming_proficiencies_for_slot(j).empty?
          @incoming_slots.push( course.incoming_proficiencies_for_slot(j) )
        end
      end
    end
  end
  
  def select
    load_course_strips(@show_proficiency)
    @selected_course = Course.find(params[:id])
    @map_options[:selected_course] = @selected_course.id
    prepare_detail_info(@selected_course)
    session[:map_options] = @map_options
    respond_to do |format|
      format.js
    end
  end
  
  def goto_page
    page = params[:page]
    level = params[:level]
    @strip_div = 'strip_' + level
    @courses_strip = MapStrip.new(level.to_i,page)
    @map_options[level.to_i][:page] = page
    session[:map_options] = @map_options
    
    respond_to do |format|
      format.js { render :template => 'map/update_strip.js.erb' }
    end
  end
  
  def clear_show_proficiency
    unless @show_proficiency.nil?
      @show_proficiency = nil
      @map_options[:show_proficiency] = nil
      session[:map_options] = @map_options
    end
  end
  
  def add_class
    @class = Instance.find(params[:id])
    new_course_instance = PathInstance.new(:instance_id => params[:id], :path_id => @current_path.id)
    
    if @current_path.nil?
      flash[:notice] = "You need a current path before you can add a class."
    else
      if @current_path.class_exists?(@class)
        @semester = @current_path.semester_class_is_in_path( @class )
        flash[:notice] = "#{@selected_course.shortname} is already in this path, in the #{@semester.fullname} semester."
      elsif not @current_path.has_required_proficiencies(@class)
        flash[:notice] = "You can't add #{@selected_course.shortname} yet, you don't have all the incoming proficiencies required."
      else
        new_course_instance.save
        @semester = @current_path.semester_class_is_in_path( @class )
        flash[:notice] = "#{@selected_course.shortname} added to path in #{@semester.fullname} semester."
        @selected_course.reload
        @current_path.reload
        clear_show_proficiency
      end
      
      @operation = 1
      @course = @class.course
      
      load_course_strips(@show_proficiency)
      prepare_detail_info(@selected_course)
      load_path
    end
    
    respond_to do |format|
      format.js { render :template => 'map/update_map.js.erb' }
    end
    flash.discard(:notice)
  end
  
  # find the path instance of this course in current path (ie the class) and delete it.
  def destroy_instance_for_course( instance_id )
    path_instance = PathInstance.find(:first, :conditions => "instance_id='#{instance_id}' AND path_id='#{@current_path.id}'")
    @course = path_instance.instance.course
    path_instance.destroy
    
    @selected_course.reload unless @selected_course.nil?
    @current_path.reload
    clear_show_proficiency
    
    load_course_strips(@show_proficiency)
    prepare_detail_info(@selected_course) unless @selected_course.nil?
    
    load_path
    @operation = 2
    
    flash[:notice] = "Removed #{@course.shortname} from path."
    respond_to do |format|
      format.js { render :template => 'map/update_map.js.erb' }
    end
    flash.discard(:notice)
  end
  
  # user clicked button in the detail section, to remove class from path
  def remove_class
    destroy_instance_for_course(@current_path.instance_for_course_in_path(@selected_course).id)
  end
  
  # user clicked link in the path section, to remove class from path
  def delete_class_from_path
    destroy_instance_for_course(params[:instance_id])
  end
  
  def look_for_proficiency
    @show_proficiency = Proficiency.find(params[:id])
    @map_options[:show_proficiency] = @show_proficiency.id
    @map_options[100][:page] = 1
    @map_options[200][:page] = 1
    @map_options[300][:page] = 1
    @map_options[400][:page] = 1
    load_course_strips(@show_proficiency)
    session[:map_options] = @map_options
    prepare_detail_info(@selected_course)
    
    respond_to do |format|
      format.js { render :template => 'map/update_map.js.erb' }
    end
  end
  
  def clear_look_for_proficiency
    @show_proficiency = nil
    @map_options[:show_proficiency] = nil
    load_course_strips(@show_proficiency)
    session[:map_options] = @map_options
    prepare_detail_info(@selected_course)
    
    respond_to do |format|
      format.js { render :template => 'map/update_map.js.erb' }
    end
  end
  
  def add_completed_course
    @user_course = current_user.user_courses.new(:course_id => @selected_course.id)
    new_course_instance = PathInstance.new(:instance_id => params[:id], :path_id => @current_path.id)
    
    if @current_path.nil?
      flash[:notice] = "You need a current path before you can add a completed course."
    else
      unless @user_course.save
        flash[:notice] = "There was an error adding #{@selected_course.title} to your list of completed courses. Please try again."
      else
        flash[:notice] = "#{@selected_course.shortname} was added to your list of completed courses."
        @current_path.reload
        current_user.reload      
        @selected_course.reload
        clear_show_proficiency
      end
    end
    
    @operation = 3
    @course = @user_course
    
    load_course_strips(@show_proficiency)
    prepare_detail_info(@selected_course)
    load_path
    
    respond_to do |format|
      format.js { render :template => 'map/update_map.js.erb' }
    end
    flash.discard(:notice)
  end
  
  # 
  def remove_from_completed_courses( acourse )
    @user_course = current_user.user_courses.find_by_course_id(acourse.id)
    prepare_detail_info(@selected_course)
    unless @user_course.destroy
      flash[:notice] = "There was an error removing #{acourse.title} from your list of completed courses. Please try again."
    else
      flash[:notice] = "Removed #{acourse.shortname} from your completed courses list."
    end
    
    current_user.reload
    @selected_course.reload
    @current_path.reload
    clear_show_proficiency
    
    load_course_strips(@show_proficiency)
    prepare_detail_info(@selected_course)
    
    @operation = 4
    @course = @user_course
    
    load_path
    
    respond_to do |format|
       format.js { render :template => 'map/update_map.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def remove_history_course( acourse )
    pei = @current_path.path_external_instances.find(:first, :conditions => {:external_instance_id => acourse.id})
    ec = pei.external_instance.external_course
    pei.destroy
    
    flash[:notice] = "Removed History and Theory course #{ec.shortname} from path."
    
    @current_path.reload
    current_user.reload
    load_path
    
    referer_array = request.referer.split('/')
    if referer_array.last == 'map'
      load_course_strips(@show_proficiency)
      prepare_detail_info(@selected_course)
      @render_map = true
      @render_history_list = false
    else
      @render_map = false
      @render_history_list = true
      @render_detail = false
    end
    
    @operation = 6
    @course = ec
    
    respond_to do |format|
       format.js { render :template => 'map/update_map.js.erb' }
    end
    flash.discard(:notice)
  end
  
  def remove_history_course_from_path
    acourse = ExternalInstance.find(params[:external_instance_id])
    remove_history_course(acourse) unless acourse.nil?
  end
   
  def remove_selected_from_completed_courses
    remove_from_completed_courses(@selected_course)
  end
  
  def remove_course_from_completed_courses
    acourse = Course.find(params[:course_id])
    remove_from_completed_courses(acourse) unless acourse.nil?
  end
  
  def send_path_advisor
    @path = Path.find(params[:id])
    UserMailer.send_path_to_advisor(@path,@path_semesters_sorted).deliver
    redirect_to map_path
  end
  
end


class MapStrip
  
  def initialize(newlevel,newpage,prof = nil)
    @level = newlevel
    @page = newpage
    @courses = Course.courses_at_level(@level,@page,prof)
  end
  
  def courses
    @courses
  end
  
  def page
    @page
  end
  
  def level
    @level
  end
  
  def list
    @courses.each do |course|
      puts course.shortname
    end
  end
    
end