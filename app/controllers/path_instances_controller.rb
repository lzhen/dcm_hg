class PathInstancesController < ApplicationController

  def index

    @path_instances = PathInstance.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => @path_instances }
    end
  end
  
  def add_path_instances
 	
 	@path_instances = PathInstance.find(:first, :conditions => [ "path_id = ? AND instance_id = ?",current_user.current_path, params[:instanceId]])

 	if @path_instances == nil
 		puts "hello, path is nil"
		@path_instances = PathInstance.new
		@path_instances.path_id = current_user.current_path
		@path_instances.instance_id = params[:instanceId].to_i
		
		respond_to do |format|
			if @path_instances.save
				format.xml  { render :xml => @path_instances, :status => :created, :location => @path_instances }
				format.json { render :json => @path_instances}
			end
		end		
	else
		puts "hello, everything is existed!"
		@path_instances.destroy
   		respond_to do |format|
       		format.json { render :json => @path_instances}
   		end
	end
	
 end
 
 
 def delete_path_instances
 	@path_instances = PathInstance.find(:all, :conditions => ["path_id = ? ", current_user.current_path])
 	@path_instances.each do |t|
 		t.destroy
 	end
   		respond_to do |format|
        	format.json { render :json => @path_instances}
   		end
 end
 
 
 def destroy
    @path_instances = PathInstance.find(params[:path_id])
    @path_instances.destroy

    respond_to do |format|
      #format.html { redirect_to(user_courses_url) }
      format.xml  { head :ok }
      end
  end

end
