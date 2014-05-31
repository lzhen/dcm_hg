module FrontHelper
  
  def course_link( title, cid )
    if Course.exists?(cid)
      link_to( title, url_for( :controller => "front", :action => 'course_info', :id => cid, :html_options => { :rel => "course_detail", :class => "poplight"} ), :remote => true )
    else
      title
    end
  end
  
  def faculty_link( name, web, unit, teaches )
    raw('<p><span class="highlight">' + link_to( name, web ) + '</span>: ' + unit + '<br/>' + teaches + '</p>')
  end
  

end
