class UserCoursesController < ApplicationController
  # before_filter :create, :except => [:create, :add_completed]
#  
 def add_completed
 	
 	@user_course = UserCourse.find(:first, :conditions => [ "user_id = ? AND course_id = ?", current_user.id, params[:courseId]])
 	
 	puts @user_course
 	if @user_course==nil
 		puts "not exist"
		@user_course = UserCourse.new
		@user_course.user_id = current_user.id
		@user_course.course_id = params[:courseId].to_i
		
		respond_to do |format|
		  if @user_course.save
			# format.html { redirect_to(@user_course, :notice => 'User course was successfully created.') }
			format.xml  { render :xml => @user_course, :status => :created, :location => @user_course }
			format.json { render :json => @user_course, :notice => 'User course was successfully created!!' }
		  else
			format.html { render :action => "new" }
			format.xml  { render :xml => @user_course.errors, :status => :unprocessable_entity }
		  end
		end
	else
		puts "exist"
		@user_course.destroy
   		respond_to do |format|
        format.json { render :json => @user_course, :notice => 'User course was successfully created!!' }
   		end
	end
	
 end
 
#  def delete_all_completed
#  	@user_courses = UserCourse.find(:all, :conditions => ["user_id = ? ", current_user.id])
#  	@user_courses.each do |t|
#  		t.destroy
#  		end
#    		respond_to do |format|
#         	format.json { render :json => @user_course, :notice => 'User course was successfully created!!' }
#    		end
#  end
 
  # GET /user_courses
  # GET /user_courses.xml
  def index
    @user_courses = UserCourse.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_courses }
      format.json {render :json => @user_courses, :only => [:id, :user_id, :course_id] }
    end
  end

  # GET /user_courses/1
  # GET /user_courses/1.xml
  def show
    @user_course = UserCourse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_course }
    end
  end

  # GET /user_courses/new
  # GET /user_courses/new.xml
  def new
    @user_course = UserCourse.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_course }
    end
  end

  # GET /user_courses/1/edit
  def edit
    @user_course = UserCourse.find(params[:id])
  end

  # POST /user_courses
  # POST /user_courses.xml
  def create
    @user_course = UserCourse.new
	puts "whatever"
	@user_course.user_id = current_user.id
	puts params[:courseId]
	@user_course.course_id = params[:courseId].to_i
	puts @user_course.course_id
	puts @user_course.user_id

    respond_to do |format|
      if @user_course.save
        # format.html { redirect_to(@user_course, :notice => 'User course was successfully created.') }
        format.xml  { render :xml => @user_course, :status => :created, :location => @user_course }
        format.json { render :json => @user_course, :notice => 'User course was successfully created!!' }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_course.errors, :status => :unprocessable_entity }
      end
    end
#     
# 	  req = ActiveSupport::JSON.decode(request.body)
# 	  if user = User.authenticate(params["email"], params["password"])
# 		session[:user_id] = user.id
# 		render :json => "{\"r\": \"t\"}" + req
# 	  else
# 		render :json => "{\"r\": \"f\"}"
# 	  end  
  end
 

  # PUT /user_courses/1
  # PUT /user_courses/1.xml
  def update
    @user_course = UserCourse.find(params[:id])

    respond_to do |format|
      if @user_course.update_attributes(params[:user_course])
        format.html { redirect_to(@user_course, :notice => 'User course was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_courses/1
  # DELETE /user_courses/1.xml
  def destroy
    @user_course = UserCourse.find(params[:id])
    @user_course.destroy

    respond_to do |format|
      format.html { redirect_to(user_courses_url) }
      format.xml  { head :ok }
      end
  end
end
