class DataController < ApplicationController
  
  def login_check
  end
  
  def proficiencies_histogram
    @prof_names = Proficiency.find(:all, :order => 'name', :select => 'name', :group => 'name')
    
    @output_count = {}
    @prof_names.each do |p|
      list = Proficiency.find(:all, :order => 'level', :conditions => "name='#{p.name}'")
      logger.debug p.name
      counts = { 
        100 => list[0].courses_with_output.size,
        200 => list[1].courses_with_output.size,
        300 => list[2].courses_with_output.size,
        400 => list[3].courses_with_output.size,
        }
      @output_count[p.name] = counts
    end
    
    @proficiencies = Proficiency.find(:all, :order => 'name,level')
    
    render 'proficiencies_histogram', :layout => false
  end
  
  def input_proficiencies_histogram
    @prof_names = Proficiency.find(:all, :order => 'name', :select => 'name', :group => 'name')
    
    @input_count = {}
    @prof_names.each do |p|
      list = Proficiency.find(:all, :order => 'level', :conditions => "name='#{p.name}'")
      logger.debug p.name
      counts = { 
        100 => list[0].courses_with_input.size,
        200 => list[1].courses_with_input.size,
        300 => list[2].courses_with_input.size,
        400 => list[3].courses_with_input.size,
        101 => list[0].slots_with_input.size,
        201 => list[1].slots_with_input.size,
        301 => list[2].slots_with_input.size,
        401 => list[3].slots_with_input.size,
        }
      @input_count[p.name] = counts
    end
    
    @proficiencies = Proficiency.find(:all, :order => 'name,level')
    
    render 'input_proficiencies_histogram', :layout => false
    render :json => @input_count
  end
  
  def combined_proficiencies_histogram
    @prof_names = Proficiency.find(:all, :order => 'name', :select => 'name', :group => 'name')
    
    @input_count = {}
    @prof_names.each do |p|
      list = Proficiency.find(:all, :order => 'level', :conditions => "name='#{p.name}'")
      counts = { 
        100 => list[0].courses_with_input.size,
        200 => list[1].courses_with_input.size,
        300 => list[2].courses_with_input.size,
        400 => list[3].courses_with_input.size,
        
        }
      @input_count[p.name] = counts
    end
    
    @output_count = {}
    @prof_names.each do |p|
      list = Proficiency.find(:all, :order => 'level', :conditions => "name='#{p.name}'")
      counts = { 
        100 => list[0].courses_with_output.size,
        200 => list[1].courses_with_output.size,
        300 => list[2].courses_with_output.size,
        400 => list[3].courses_with_output.size,
        }
      @output_count[p.name] = counts
    end
    
    @proficiencies = Proficiency.find(:all, :order => 'name,level')
    
    respond_to do |format|
      format.html { render 'combined_proficiencies_histogram', :layout => false }
      format.csv { render 'combined_proficiencies_histogram', :layout => false, :content_type => "text/csv; charset=iso-8859-1;" }
    end
  end
  
  def courses_graph
    @courses = Course.find(:all)
    @course_links = []
    @courses.each do |course|
      course.outgoing_proficiencies.each do |out_prof|
        @courses.each do |other_course|
          if other_course.incoming_proficiencies.include?(out_prof)
            @course_links.push("\"" + course.shortname_with_id + "\"" + " -> " + "\"" + other_course.shortname_with_id + "\"")
          end
        end
      end
    end
    render 'courses_graph', :layout => false
  end
  
  def proficiencies_graph
    @proficiencies = Proficiency.find(:all)
    @courses = Course.find(:all)
    
    @prof_links = []
    @proficiencies.each do |prof|
      @courses.each do |course|
        if course.outgoing_proficiencies.include?(prof)
          course.incoming_proficiencies.each do |in_prof|
            @prof_links.push("\"" + in_prof.fullname + "\"" + " -> " + "\"" + prof.fullname + "\"")
          end
        end
      end
    end
    
    render 'proficiencies_graph', :layout => false
  end
  
  def mixed_graph
    @courses = Course.find(:all)
    @mixed_links = []
    @courses.each do |course|
      course.incoming_proficiencies.each do |in_prof|
        @mixed_links.push("\"" + in_prof.fullname + "\"" + " -> " + "\"" + course.shortname_with_id + "\"")
      end
      course.outgoing_proficiencies.each do |out_prof|
        @mixed_links.push("\"" + course.shortname_with_id + "\"" + " -> " + "\"" + out_prof.fullname + "\"")
      end
    end
    render 'mixed_graph', :layout => false
  end
  
  def check_paths
    @courses = Course.find(:all, :conditions => "number >= '200'", :order => 'number, prefix, title')
    @courses_inputs = {}
    @courses.each do |course|
      puts "*** Course: #{course.fullname}"
      
      slots = []
      
      course.incoming_proficiency_arrays.each do |slot|
        puts "    Slot: #{slot.size} proficiencies"
        inputs = []
        slot.each do |prof|
          course_list = prof.courses_with_output
          inputs.push(course_list)
        end
        result = "        Inputs: "
        inputs.each do |list|
          result += list.size.to_s + ' '
        end
        puts result
        
        slots.push(inputs)
      end
      
      puts
      puts
      
      @courses_inputs[course.id] = slots
      
    end
    
    render 'check_paths', :layout => false
  end
  
  def courses
    if params[:level].nil?
      level_min = 100
      level_max = 199
    else
      level_min = params[:level].to_i
      level_max = level_min + 99
    end
    @courses = Course.find(:all, :conditions => "number >= '#{level_min}' AND number <= '#{level_max}'")
    render :json => @courses
  end
  
  def get_user
    if current_user.nil?
      puts "warning, current_user is nil"
    end
    @user = User.find(:all, :conditions => "id = '#{current_user.id}'")
    if @user.nil?
      puts "warning, @user is nil"
    end
    if @user.size == 0
      puts "info, @user.size is zero?"
    end
    render :json => @user
  end
  
  def get_current_path
    @path = Path.find( current_user.current_path )
    render :json => @path
  end
  
  def get_classes_in_current_path
    render :json => @path_semesters_sorted
  end
  
  def semesters
    @semesters = Semester.find(:all)
    render :json => @semesters
  end
  
  def proficiencies
    @proficiencies = Proficiency.find(:all)
    render :json => @proficiencies
  end
  
  def course_proficiencies
    @course_proficiencies = CourseProficiency.find(:all)
    render :json => @course_proficiencies
  end
  
  def delete_class_from_path
     old_path_class = PathInstance.find(:first, :conditions => "instance_id='#{params[:instance_id]}' AND path_id='#{params[:path_id]}'")
     old_path_class.destroy
     
     # fix this - send a json "ok" reply is no error
     render :json => "ok"
  end
  
  def classes_for_course
     @course = Course.find(params[:course_id])
     render :json => @course.instances
  end
   
  def add_class_to_path
     new_path_class = PathInstance.new(:instance_id => params[:instance_id], :path_id => params[:path_id])
     @path = Path.find(params[:path_id])
     @class = Instance.find(params[:instance_id])
     
     #if @path.class_exists?(@class)
     #  flash[:notice] = "This class has already been added to this path"
     #elsif not @path.has_required_proficiencies(@class)
     #   flash[:notice] = "You do not have all the incoming proficiencies required for this course."
     #else
     #   new_path_class.save
     #end
     new_path_class.save
     
     # fix this - send a json "ok" reply is no error
     render :json => "ok"
   end 
  
   def catcher
     render :nothing => true
   end
   
  def degrees
    students = User.find(:all, :conditions => "user_type = 'Student'")
    all_degrees = students.map { |s| s.degree.nil? ? "Unknown" : s.degree }
    @degrees = all_degrees.uniq
    unless @degrees.nil?
      @degrees.sort! {|x,y| x <=> y }
    end
    @degree_count = {}
    all_degrees.each do |d|
      if @degree_count[d].nil?
        @degree_count[d] = 1
      else
        @degree_count[d] += 1
      end
    end
    render 'degrees', :layout => false
  end
  
end
