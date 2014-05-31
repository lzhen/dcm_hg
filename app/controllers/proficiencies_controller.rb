class ProficienciesController < ApplicationController
  
  before_filter :login_check, :except => [:index]
  
   respond_to:json
  
  def index
    @all_proficiencies = Proficiency.all
    per_page = 40
    unless params[:search_text].nil? or params[:search_text].empty?
      query = params[:search_text]
      @proficiencies = Proficiency.paginate_search(query, :per_page => per_page, :page => params[:page], :group => :name, :order => 'name, level').uniq
    else
      @proficiencies = Proficiency.paginate(:per_page => per_page, :page => params[:page], :group => :name, :order => 'name, level')
    end
    
    
    flash[:notice] = nil
    
    # TODO: refactor this into the respond_do, with a js.erb template
    #if request.xml_http_request?
    #  render :partial => "proficiency_list", :layout => false
    # end
    
    respond_to do |format|
      	format.html
      	format.xml {render :xml => @all_proficiencies, :only => [:id, :level, :name] }
      
      	format.json {
       		@proficiencies = Proficiency.all
       		respond_with(@proficiencies)
     	}
     	format.js { render :partial => "proficiency_list", :layout => false }
     	
    end
    
  end

  def show
    @proficiency = Proficiency.find(params[:id])
  end
  
  def new
    @title = "Create a new Proficiency"
    unless params[:proficiency].nil?
      @proficiency = Proficiency.new
    else
      flash[:notice] = "Please enter the details of the proficiency."
    end
  end

  def create
    unless params[:proficiency].nil?
      1. upto 4 do |i|
        @proficiency = Proficiency.new(:name => params[:proficiency][:name], :level => (i*100) )
        @proficiency.save
      end
    else
      flash[:notice] = "Please enter the details of the proficiency."
    end
    #if @proficiency.save
      flash[:notice] = "New proficiency #{@proficiency.name} has been created."
      redirect_to proficiencies_path
    #else
      #render :action => 'new'
    #end
  end

  def edit
    @title = "Edit Proficiency Name"
    @proficiency = Proficiency.find(params[:id])
  end

  def update
    @proficiency = Proficiency.find(params[:id])
    if @proficiency.update_attributes(params[:proficiency])
      flash[:notice] = "The proficiency #{@proficiency.name} was successfully updated."
      redirect_to proficiencies_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @proficiency = Proficiency.find(params[:id])
    @proficiency.destroy
    redirect_to proficiencies_path
  end
  
  def search
    if params[:search_text]
      query = params[:search_text]
      #@proficiencies = Proficiency.find_with_ferret(query, :limit => :all).uniq
      @proficiencies = []
    end
    if request.xml_http_request?
      render :partial => "proficiency_list", :layout => false
      #
    end
  end
  
  


end
