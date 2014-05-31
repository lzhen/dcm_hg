xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "ASU Digital Culture Events"
    xml.description "Events at Arizona State University's Digital Culture program"
    xml.link formatted_events_url(:rss)
    
    for event in @events
      xml.item do
        xml.title event.title
        xml.description (event.happens_at.strftime("%A %B %d, %Y at %l:%M%p") + '. ' + event.body)
        xml.pubDate event.created_at.strftime("%a, %d %b %Y %H:%M%:%S MST")
        #xml.link formatted_event_url(event, :rss)
      end
    end
  end
end