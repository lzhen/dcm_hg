class RecommendationsController < ApplicationController
  
  def index
     @title = "List of All Reviews"
     @recommendations = Recommendation.all
  end
  
  def edit
     @title = "Edit Review"
     @recommendation = Recommendation.find(params[:id])
   end

   def update
     @recommendation = Recommendation.find(params[:id])
     if @recommendation.update_attributes(params[:recommendation])
       flash[:notice] = "The recommendation was successfully updated."
       redirect_to recommendations_path
     else
       render :action => 'edit'
     end
   end

  def destroy
    @recommendation = Recommendation.find(params[:id])
    @recommendation.destroy
    redirect_to recommendations_path
  end
end
