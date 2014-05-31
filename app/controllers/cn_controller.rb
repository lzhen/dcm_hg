class CnController < ApplicationController
  
  layout "front"
  before_filter :login_check, :except => [:index]
  
  def index
    @page_title = 'Cultural Networks | Digital Culture | ASU Herberger Institute for Design and the Arts'
    @section_option = ""
    @section_option = "section-wide" if current_user.nil?
  end

end
