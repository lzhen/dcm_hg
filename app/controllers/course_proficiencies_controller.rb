class CourseProficienciesController < ApplicationController
  # GET /course_proficiencies
  # GET /course_proficiencies.xml
  def index
    @course_proficiencies = CourseProficiency.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @course_proficiencies }
      format.json {render :json => @course_proficiencies }
     	
    end
  end

  # GET /course_proficiencies/1
  # GET /course_proficiencies/1.xml
  def show
    @course_proficiency = CourseProficiency.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @course_proficiency }
    end
  end

  # GET /course_proficiencies/new
  # GET /course_proficiencies/new.xml
  def new
    @course_proficiency = CourseProficiency.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course_proficiency }
    end
  end

  # GET /course_proficiencies/1/edit
  def edit
    @course_proficiency = CourseProficiency.find(params[:id])
  end

  # POST /course_proficiencies
  # POST /course_proficiencies.xml
  def create
    @course_proficiency = CourseProficiency.new(params[:course_proficiency])

    respond_to do |format|
      if @course_proficiency.save
        format.html { redirect_to(@course_proficiency, :notice => 'Course proficiency was successfully created.') }
        format.xml  { render :xml => @course_proficiency, :status => :created, :location => @course_proficiency }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course_proficiency.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /course_proficiencies/1
  # PUT /course_proficiencies/1.xml
  def update
    @course_proficiency = CourseProficiency.find(params[:id])

    respond_to do |format|
      if @course_proficiency.update_attributes(params[:course_proficiency])
        format.html { redirect_to(@course_proficiency, :notice => 'Course proficiency was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course_proficiency.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /course_proficiencies/1
  # DELETE /course_proficiencies/1.xml
  def destroy
    @course_proficiency = CourseProficiency.find(params[:id])
    @course_proficiency.destroy

    respond_to do |format|
      format.html { redirect_to(course_proficiencies_url) }
      format.xml  { head :ok }
    end
  end
end
