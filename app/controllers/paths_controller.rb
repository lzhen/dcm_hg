class PathsController < ApplicationController
  
  before_filter :login_check, :except => [:show]
  
  def index
    @title = "List of My Paths"
    
    @paths = Path.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => @paths }
    end
  end
  
  def add_user_path
 	@paths = Path.find(:first, :conditions => [ "id = ? AND student_id = ?",params[:id],current_user.id])

	if params[:id].nil?
		puts "path is built!"
		@paths = Path.new
		@paths.id = params[:id]
		@paths.student_id = current_user.id
		
		respond_to do |format|
			if current_user.path.save
				# format.html { redirect_to(@user_course, :notice => 'User course was successfully created.') }
				format.xml  { render :xml => current_user.path, :status => :created, :location => current_user.path }
				format.json { render :json => current_user.path, :notice => 'User course was successfully created!!' }
			end
		end
	else
	  puts "path exists!"		
	end	
  end

  def show
    @path = Path.find(params[:id])
    @path_dictionary = @path.path_dictionary()
    @courses = @path.instances.collect { |i| i.course }
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @path.instances.to_xml( :include => { :course => {:only => [:id, :title, :prefix, :number, :description],
                                                                                    :include => { :course_proficiencies => { :only => [:proficiency_direction, :slot], 
                                                                                                                            :include => {:proficiency => { :only => [:id, :name, :level] }
                                                                                                                                        }
                                                                                                                           }
                                                                                                }
                                                                                   },
                                                                        :semester => {:only => [:name,:year]} }
                  )}
    end
  end
  
  def turn_off_current_path
    current_user.current_path = nil
    current_user.save
    redirect_to paths_path
  end

  def new
    @path = current_user.paths.new
    render :action => 'new'
  end

  def create
    unless params[:path].nil?
      @path = current_user.paths.new(params[:path])
      #@path.student_id = current_user.id
      if @path.save
        if current_user.paths.size == 1
          @path.reload
          current_user.update_attribute(:current_path, @path.id)
          current_user.reload
        end
        redirect_to paths_path
      else
        flash[:notice] = "There was an error saving the path. Please try again."
        render :action => 'new'
      end
    else
      flash[:notice] = "Please enter the name of the path."
      render :action => 'new'
    end
  end

  def edit
    @title = "Edit Path Details"
    @path = current_user.paths.find(params[:id])
  end

  def update
    @path = current_user.paths.find(params[:id])
    if @path.update_attributes(params[:path])
      flash[:notice] = "The path was successfully updated."
      redirect_to paths_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @path = current_user.paths.find(params[:id])
    @path.destroy
    flash[:notice] = "The path was successfully deleted."
    redirect_to paths_path
  end
  
  def add_class_to_path
    if params[:path_id].nil?
      flash[:notice] = "You need a current path before you can add a class."
    else
      new_course_instance = PathInstance.new(:instance_id => params[:instance_id], :path_id => params[:path_id])
      @path = current_user.paths.find(params[:path_id])
      @class = Instance.find(params[:instance_id])
      @course = Course.find(@class.course_id)
      if @path.class_exists?(@class)
        @semester = @path.semester_class_is_in_path( @class )
        flash[:notice] = "#{@course.shortname} is already in this path, in the #{@semester.fullname} semester."
      elsif not @path.has_required_proficiencies(@class)
        flash[:notice] = "You can't add #{@course.shortname} yet, you don't have all the incoming proficiencies required."
      else
        new_course_instance.save
        @semester = @path.semester_class_is_in_path( @class )
        flash[:notice] = "#{@course.shortname} added to path in #{@semester.fullname} semester."
      end
      load_path
    end
    
    respond_to do |format|
      format.js { render :template => 'paths/update_path_list.js.rjs' }
    end
  end
  
  def set_as_current_path
    @path = current_user.paths.find(params[:id])
    unless @path.nil?
      current_user.current_path = params[:id]
      current_user.save
      flash[:notice] = "The path '#{@path.title}' is now the current path."
    end
    redirect_to paths_path
  end
     
  def delete_class_from_path
    path_instance = PathInstance.find(:first, :conditions => "instance_id='#{params[:instance_id]}' AND path_id='#{params[:path_id]}'")
    instance = path_instance.instance
    @course = instance.course
    @semester = instance.semester
    path_instance.destroy
    load_path
    flash[:notice] = "Removed #{@course.shortname} from path."
    respond_to do |format|
      format.js { render :template => 'paths/update_path_list.js.rjs' }
    end
  end
  
  def remove_course_from_completed_courses
    @course = Course.find(params[:course_id])
    @user_course = current_user.user_courses.find_by_course_id(@course.id)
    @user_course.destroy
    load_path
    flash[:notice] = "Removed #{@course.shortname} from completed courses list."
    respond_to do |format|
      format.js { render :template => 'paths/update_path_list.js.rjs' }
    end
  end
  
  def remove_history_course( acourse )
    pei = @current_path.path_external_instances.find(:first, :conditions => {:external_instance_id => acourse.id})
    ec = pei.external_instance.external_course
    pei.destroy
    
    flash[:notice] = "Removed History and Theory course #{ec.shortname} from path."
    
    @current_path.reload
    current_user.reload
    load_path
    
    @render_map = false
    @render_history_list = false
    
    respond_to do |format|
       format.js { render :template => 'map/remove_history_class.js.rjs' }
    end
  end
  
  def remove_history_course_from_path
    acourse = ExternalInstance.find(params[:external_instance_id])
    remove_history_course(acourse) unless acourse.nil?
  end
  
end
