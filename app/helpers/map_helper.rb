module MapHelper
  
  def course_box(course)
    if course == @selected_course
      html  = "<div class=\"course_box selected_box\">"
    elsif @current_path.course_exists?(course) or @current_path.previous_course_exists?(course)
      html  = "<div class=\"course_box inpath_box\">"
    elsif course.outgoing_proficiencies.include?(@show_proficiency)
      html  = "<div class=\"course_box prof_box\">"
    else
      html  = "<div class=\"course_box\">"
    end
    html << "  <p class=\"box_short\">" + course.shortname + "</p>"
    html << "  <p class=\"box_title\">" + course.title + "</p>"
    html << "</div>"
    raw(html)
  end
  
  def course_prev_box(list)
    if list.courses.previous_page.nil?
      html = "<div class=\"courses_prev courses_prev_disable\"><img src=\"images/courses_prev.png\" width=\"32\" height=\"32\" class=\"pager\" /></div>"
    else
      div = "<div class=\"courses_prev\"><img src=\"images/courses_prev_active.png\" width=\"32\" height=\"32\" class=\"pager\" /></div>"
      html = link_to( raw(div), url_for( :controller => "map", :action => 'goto_page', :level => list.level, :page => list.courses.previous_page() ), :remote => true )
    end
    raw(html)
  end
  
  def course_next_box(list)
    if list.courses.next_page.nil?
      html = "<div class=\"courses_next courses_next_disable\"><img src=\"images/courses_next.png\" width=\"32\" height=\"32\" class=\"pager\" /></div>"
    else
      div = "<div class=\"courses_next\"><img src=\"images/courses_next_active.png\" width=\"32\" height=\"32\" class=\"pager\" /></div>"
      html = link_to( raw(div), url_for( :controller => "map", :action => 'goto_page', :level => list.level, :page => list.courses.next_page() ), :remote => true )
    end
    raw(html)
  end
  
  
end
