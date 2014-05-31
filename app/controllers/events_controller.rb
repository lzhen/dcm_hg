class EventsController < ApplicationController
  
  layout "front"
  protect_from_forgery :only => [:create, :delete, :update]
  before_filter :login_check, :except => [:index]
  before_filter :authorize_editor_only, :except => [:index]
  
  
  def admin
    @page_title = 'Digital Culture'
    @section_option = ""
    @section_option = "section-wide" if current_user.nil?
    @events = Event.find(:all, :order => "happens_at DESC")
  end
  
  def index
    @page_title = 'Digital Culture'
    @section_option = ""
    @section_option = "section-wide" if current_user.nil?
    @timeNow = DateTime.now
    @dateSoon = @timeNow + 7
    @events = Event.find(:all, :conditions => ['happens_at <= ?', @dateSoon], :order => "happens_at DESC", :limit => 10)
    @coming_events = Event.find(:all, :conditions => ['happens_at > ?', @dateSoon], :order => "happens_at DESC")
  end

  def new
    @event = Event.new
  end

  def create
    unless params[:event].nil?
      @event = Event.new(params[:event])
    else
      flash[:notice] = "Please enter details for the new event."
    end
    if @event.save
      flash[:notice] = "New event \"#{@event.title}\" has been created."
      redirect_to :controller => 'events', :action => 'admin'
    else
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    
    if @event.update_attributes(params[:event])
      flash[:notice] = "The event #{@event.title} was successfully updated."
      redirect_to :controller => 'events', :action => 'admin'
    else
      render :action => 'edit'
    end
  end

  def show
    @event = Event.find(params[:id])
  end
  
  def authorize_editor_only
    unless current_user.is_event_editor
      flash[:notice] = "Only administrator users can view the resource #{params[:controller]}/#{params[:action]}."
      redirect_to :controller => 'events', :action => 'index'
    end
    true
  end
  
  def destroy
    @event = Event.find(params[:id])
    flash[:notice] = "The event #{@event.title} was successfully deleted."
    @event.destroy
    redirect_to :controller => 'events', :action => 'admin'
  end

end
