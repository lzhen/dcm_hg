atom_feed do |feed|
  feed.title("ASU Digital Culture Events")
  feed.updated((@events.first.updated_at))

  for event in @events
    feed.entry(event) do |entry|
      entry.title(event.title)
      entry.published(event.created_at.to_s(:rfc822))
      entry.content((event.happens_at.strftime("%A %B %d, %Y at %l:%M%p") + '. ' + event.body), :type => 'html')
    end
  end
end