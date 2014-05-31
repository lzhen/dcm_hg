class ReviewsController < ApplicationController
  
  def index
     @title = "List of All Reviews"
     @reviews = current_user.reviews.find(:all)
  end
  
  def edit
     @title = "Edit Review"
     @review = Review.find(params[:id])
   end

   def update
     @review = Review.find(params[:id])
     if @review.update_attributes(params[:review])
       flash[:notice] = "The review was successfully updated."
       redirect_to reviews_path
     else
       render :action => 'edit'
     end
   end

end
