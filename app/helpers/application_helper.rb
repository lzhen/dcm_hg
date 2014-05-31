module ApplicationHelper
  
  def dcm_formatted_datetime( dt )
    month_names = ['-','Jan.','Feb.','March','April','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.']
    mi = ' p.m.'
    mi = ' a.m.' if dt.strftime("%p") == 'AM'
    time_str = dt.strftime("%l:%M") + mi
    if time_str == '12:00 p.m.'
      time_str = 'noon'
    elsif time_str == '12:00 a.m.'
      time_str = 'midnight'
    end
    format_str = "%A, " + month_names[dt.month()] + " %d, %Y, " + time_str
    dt.strftime(format_str)
  end
  
  def dcm_edit_check_box( label, form, field, user_options={} )
    options = {:size => 80}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="Label Right Column1 FloatLeft FloatClear">' + label + '</div>'
    html << '  <div class="Left Column2 FloatLeft Field">' + form.check_box(field, options) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  def dcm_edit_text_field( label, form, field, user_options={} )
    options = {:size => 80}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="Label Right Column1 FloatLeft FloatClear">' + label + '</div>'
    html << '  <div class="Left Column2 FloatLeft Field">' + form.text_field(field, :size => options[:size]) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  def dcm_edit_text_field_with_auto_complete( label, id, field, user_options={} )
    options = {:size => 80}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="Label Right Column1 FloatLeft FloatClear">' + label + '</div>'
    html << '  <div class="Left Column2 FloatLeft Field">' + text_field_with_auto_complete(id, field, :size => options[:size]) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  def dcm_edit_text_area( label, form, field, user_options={} )
    options = { :cols => 80,
                :rows => 4}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="Label Right Column1 FloatLeft FloatClear">' + label + '</div>'
    html << '  <div class="Left Column2 FloatLeft Field">' + form.text_area(field, :rows => options[:rows], :cols => options[:cols]) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  def dcm_edit_date( label, id, field, user_options={} )
    options = { :start_year => 2000,
                :include_blank => true}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="Label Right Column1 FloatLeft FloatClear">' + label + '</div>'
    html << '  <div class="Left Column2 FloatLeft Field">' + date_select( id, field, :include_blank => options[:include_blank], :start_year => options[:start_year] ) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  def dcm_edit_datetime( label, id, field, user_options={} )
    options = { :start_year => 2000,
                :include_blank => true}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="Label Right Column1 FloatLeft FloatClear">' + label + '</div>'
    html << '  <div class="Left Column2 FloatLeft Field">' + datetime_select( id, field, :include_blank => options[:include_blank], :start_year => options[:start_year] ) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  def dcm_edit_select( label, id, field, select_options, user_options={} )
    options = { 
      :label_class => 'Label Right Column1 FloatLeft FloatClear',
      :field_class => 'Left Column2 FloatLeft Field', 
      :include_blank => true}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="' + options[:label_class] + '">' + label + '</div>'
    html << '  <div class="' + options[:field_class] + '">' + select( id, field, select_options ) + '</div>'
    html << '</div>'
    raw(html)
  end
  
  
  
  def dcm_show_text( label, field, user_options={} )
    options = {
      :label_class => 'Label Right Column1 FloatLeft FloatClear',
      :field_class => 'Left Column2 FloatLeft Field',
      :size => 80, 
      :font_size => 'Normal'}.merge! user_options
    html  = '<div class="Row">'
    html << '  <div class="' + options[:label_class] + '">' + label + '</div>'
    field = '-' if field.nil?
    html << '  <div class="' + "#{options[:field_class]} #{options[:font_size]}" + '">' + field + '</div>'
    html << '</div>'
    raw(html)
  end
  
  
  
  
  def sort_link_helper(text, param, action, update_div)
    key = param
    #key += " DESC" if params[:sort] == param
    if params[:sort] == param
      list_of_sort_options = key.split(',')
      if list_of_sort_options.size == 1
        key += " DESC"
      else
        temp_list = list_of_sort_options.collect {|x| x + " DESC" }
        key = temp_list.join(',')
      end
    end

    options = {
        :url => {:action => action, :params => params.merge({:sort => key, :page => nil})},
        :update => update_div, :method => :get
    }
    html_options = {
      :title => "Sort by this field",
      :href => url_for(:action => action, :params => params.merge({:sort => key, :page => nil}))
    }
    link_to(text, options, html_options, :remote => true)
  end
  
  def header_sortable( title, name, action='index', update_div='courses', classname='column_header' )
    html  = "<th scope=\"col\" class=\"#{classname}\">" + sort_link_helper( title, name, action, update_div ) + "</th>"
    raw(html)
  end
  
  
  def content_sheet_div
    if (not current_user.nil?) and current_user.has_path?
      html = '<div class="sheet">'
    else
      html = '<div class="wide_sheet">'
    end
    raw(html)
  end
  
  
  def __dcm_edit_check_box( label, form, field, user_options={} )
    options = {:size => 80}.merge! user_options
    html  = '<tr>'
    html << '  <td class="Label Right">' + label + '</td>'
    html << '  <td class="Left">' + form.check_box(field) + '</td>'
    html << '</tr>'
  end
  
  def __dcm_edit_text_field( label, form, field, user_options={} )
    options = {:size => 80}.merge! user_options
    html  = '<tr>'
    html << '  <td class="Label Right">' + label + '</td>'
    html << '  <td class="Left">' + form.text_field(field, :size => options[:size]) + '</td>'
    html << '</tr>'
  end
  
  def __dcm_edit_text_field_with_auto_complete( label, id, field, user_options={} )
    options = {:size => 80}.merge! user_options
    html  = '<tr>'
    html << '  <td class="Label Right">' + label + '</td>'
    html << '  <td class="Left">' + text_field_with_auto_complete(id, field, :size => options[:size]) + '</td>'
    html << '</tr>'
  end
  
  
  def __dcm_edit_text_area( label, form, field, user_options={} )
    options = { :cols => 80,
                :rows => 4}.merge! user_options
    html  = '<tr>'
    html << '  <td class="Label Right">' + label + '</td>'
    html << '  <td class="Left">' + form.text_area(field, :rows => options[:rows], :cols => options[:cols]) + '</td>'
    html << '</tr>'
  end
  
  def __dcm_edit_date( label, id, field, user_options={} )
    options = { :start_year => 2000,
                :include_blank => true}.merge! user_options
    html  = '<tr>'
    html << '  <td class="Label Right">' + label + '</td>'
    html << '  <td class="Left">' + date_select( id, field, :include_blank => options[:include_blank], :start_year => options[:start_year] ) + '</td>'
    html << '</tr>'
  end
  
  def __dcm_edit_select( label, id, field, select_options, user_options={} )
    options = { 
      :label_class => 'Label Right',
      :field_class => 'Left', 
      :include_blank => true}.merge! user_options
    html  = '<tr>'
    html << '  <td class="' + options[:label_class] + '">' + label + '</td>'
    html << '  <td class="' + options[:field_class] + '">' + select( id, field, select_options ) + '</td>'
    html << '</tr>'
  end
  
  def __dcm_show_text( label, field, user_options={} )
    options = {
      :label_class => 'Label Right',
      :field_class => 'Left',
      :size => 80, 
      :font_size => 'Normal'}.merge! user_options
    html  = '<tr>'
    html << '  <td class="' + options[:label_class] + '">' + label + '</td>'
    field = '-' if field.nil?
    html << '  <td class="Left ' + "#{options[:font_size]}" + '">' + field + '</td>'
    #if field.nil?
    #  html << '  <td class="Left ' + "#{options[:font_size]}" + '">-</td>'
    #else
    #  html << '  <td class="Left ' + "#{options[:font_size]}" + '">' + field + '</td>'
    #end
    html << '</tr>'
  end

end
