module HelpHelper
  
  def help_movie( movie, image, width, height )
    html  = '<a'
    html << '  href="' + movie + '"'
    html << '  style="display:block;width:' + width.to_s + 'px;height:' + height.to_s + 'px"'
    html << '  id="player">'
    html << '</a>' 
  	html << '<script>'
  	html << ' 	flowplayer("player", "/flash/flowplayer-3.1.5.swf", {'
  	html << '		clip:  { '
  	html << '			autoPlay: false, '
  	html << '		  autoBuffering: true '
  	html << '		  } '
  	html << ' 	});'
  	html << '</script>'
  end
  
  #tried this code instead of above for multiple players on same page, but player controls don't work.
  #I'm missing something.
  #html  = '<a'
  #html << ' class="player"'
  #html << '  href="' + movie + '"'
  #html << '  style="background-image:url(' + image + ');display:block;width:' + width.to_s + 'px;height:' + height.to_s + 'px"'
  #html << '  id="player">'
  #html << '<img src="../images/play_large.png" />'
  #html << '</a>' 
	#html << '<script>'
	#html << ' 	flowplayer("a.player", "/flash/flowplayer-3.1.5.swf", {'
	#html << '		clip:  { '
	#html << '			autoPlay: true, '
	#html << '		  autoBuffering: true '
	#html << '		  } '
	#html << ' 	});'
	#html << '</script>'
	
	def toggle_answer_for_question( question, answer )
	  html = '<a href="#"'
	  html << ' onclick="'
	  html << " Effect.toggle('" + answer + "','blind'); return false; "
	  html << '">'
	  html << question
	  html << '</a>'
	  html << '<div id="' + answer + '" ' + 'style="display:none">'
	  html << render(:partial => answer)
	  html << '</div>'
  end
  
end
