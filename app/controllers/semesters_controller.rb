class SemestersController < ApplicationController
  
  def index
    @title = "List of All Semesters"
    @all_semesters = Semester.all
    

    respond_to do |format|
     	format.json {render :json => @all_semesters, :only => [:id, :name, :year] }
     end
  end

  def show
    @semester = Semester.find(params[:id])
  end
  
  def new
    @title = "Create a new Semester"
    unless params[:semester].nil?
      @semester = Semester.new
    else
      flash[:notice] = "Please enter all the details of the semester."
    end
  end

  def create
    unless params[:semester].nil?
      @semester = Semester.new(params[:semester])
    else
      flash[:notice] = "Please enter all the details for the semester."
    end
    if @semester.save
      flash[:notice] = "New semester #{@semester.name} has been created."
      redirect_to semesters_path
    else
      render :action => 'new'
    end
  end

  def edit
    @title = "Edit Semester Details"
    @semester = Semester.find(params[:id])
  end

  def update
    @semester = Semester.find(params[:id])
    if @semester.update_attributes(params[:semester])
      flash[:notice] = "The semester #{@semester.name} was successfully updated."
      redirect_to semesters_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @semester = Semester.find(params[:id])
    @semester.destroy
    redirect_to semesters_path
  end
  
  def search
    if params[:q]
      query = params[:q]
      @semesters = Semester.find_by_contents(query, :limit => :all).uniq
    end
  end
  
end
