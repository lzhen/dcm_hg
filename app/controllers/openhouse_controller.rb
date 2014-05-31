class OpenhouseController < ApplicationController
 
  layout "front"
  before_filter :login_check, :except => [:index, :speakers, :installations, :performances]
  before_filter :setup_openhouse
  
  def index
    @page_title = 'Open House | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @current_menu["index"] = "current"
  end
  
  def speakers
    @page_title = 'Open House:Speakers | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @current_menu["speakers"] = "current"
  end
   
  def installations
    @page_title = 'Open House:Installations and Exhibits | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @current_menu["installations"] = "current"
  end
    
  def performances
    @page_title = 'Open House:Performances | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @current_menu["performances"] = "current"
  end
  
  def setup_openhouse
    @section_option = ""
    @section_option = "section-wide" if current_user.nil?
    @current_menu = Hash.new("not-current")
  end
   
end
