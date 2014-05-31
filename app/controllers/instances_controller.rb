class InstancesController < ApplicationController

 before_filter :login_check, :except => [:index]
  
 
  def index
    @all_instances = Instance.all

    respond_to do |format|
      	format.html
      	format.xml {render :xml => @all_instances, :only => [:id, :course_id, :semester_id] }
    
     	format.js { render :partial => "instances_list", :layout => false }
     	
     	format.json {render :json => @all_instances, :only => [:id, :course_id, :semester_id, :number] }
     	

     	
  end
    
    
  end

  
end
