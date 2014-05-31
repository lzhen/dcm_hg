module CoursesHelper
  
  def search_observe_field( field_id )
    observe_field( field_id, :frequency => 1, :update => 'courses',
  		             :url => {:action => 'index'}, :method => :get, :with => field_id )
  end
  
  def change_proficiency_level( course, prof )
    logger.info "change -> " + course.level.to_s + " " + prof.proficiency.level.to_s
    html = ''
    if course.level >= 300
      if prof.proficiency.level >= 200
        html += ' ' + link_to('Lower', url_for( :action => ('lower_incoming_proficiency_level'), :course_proficiency_id => prof, :id => course), :remote => true)
      end
      if prof.proficiency.level < (course.level - 100)
        html += ' ' + link_to('Raise', url_for( :action => ('raise_incoming_proficiency_level'), :course_proficiency_id => prof, :id => course), :remote => true)
      end
    end
    raw(html)
  end
  
  def start_year
    Date.today.year()
  end
  
  def end_year
    Date.today.year() + 6
  end
  
  def show_proficiencies_in_list(course)
    html = ''
    
    incoming_list = course.incoming_proficiency_string
    unless incoming_list.nil? or incoming_list.empty?
      html += '<p class="Proficiencies"> Incoming: ' + incoming_list + ' </p>'
    end
    
    outgoing_list = course.outgoing_proficiency_string
    unless outgoing_list.nil? or outgoing_list.empty?
      html += '<p class="Proficiencies"> Outgoing: ' + outgoing_list + ' </p>'
    end
		
	  raw(html)
  end
  
  def count_modifier( prof )
    if prof.courses_with_output.size == 0
      html='Red'
    else
      html=''
    end
    raw(html)
  end
  
end
