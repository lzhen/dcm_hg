class Course < ActiveRecord::Base
 
  has_many :course_proficiencies, :dependent => :destroy
  # has_many :proficiencies, :through => :course_proficiencies, :select => "course_proficiencies.proficiency_direction, proficiencies.*"
  has_many :proficiencies, :through => :course_proficiencies, :select => "course_proficiencies.proficiency_direction, proficiencies.*"
  
  has_many :user_courses, :dependent => :destroy
  has_many :users, :through => :user_courses
  
  has_many :instances, :order => 'semester_id', :dependent => :destroy
  has_one :recommendation
  has_many :reviews
  
  
  default_value_for :anticipated_start_date do
    today = Date.today
    if (today > Date.civil(today.year(),8,1))
      Date.civil(today.year()+1,8,15)
    else
      Date.civil(today.year(),8,15)
    end
  end
  
  default_value_for :is_existing, true
  default_value_for :frequency, 'Every Year'
  default_value_for :reserved_seats, 100
  default_value_for :classification, 'Equally Technological and Humanistic'
  default_value_for :facility_needs, 'Reconfigurable DC Room- 25'
  default_value_for :total_seats, 20
  default_value_for :credit_hours, 3

 
  validates_presence_of :title, :prefix, :number, :description, :credit_hours, :anticipated_start_date, :classification, :frequency, :facility_needs, :total_seats, :reserved_seats
  
  validates_numericality_of :number, :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 799
  
  #validates_inclusion_of :special_incoming_proficiencies, :in => " ", :if => :is_general, :message => "are only allowed for non general courses."
  #validates_inclusion_of :special_outgoing_proficiencies, :in => " ", :if => :is_general, :message => "are only allowed for non general courses."
=begin
  validates :number, :presence => true,
  def validate
    number_as_int = self.number.to_i
    unless number_as_int >= 100 and number_as_int <= 799
      errors.add("number", "must be an integer value between 100 and 799")
    end
    unless prefix.nil?
      unless prefix == prefix.upcase
        errors.add("prefix", "must be uppercase letters")
      end
    end
  end
=end
 
  CLASSIFICATION_OPTIONS = [
    ["Please Select the Course Classification",""],
    ["Technological-Humanistic","Technological-Humanistic"],
    ["Humanistic-Technological","Humanistic-Technological"],
    ["Equally Technological and Humanistic","Equally Technological and Humanistic"]
    ].freeze
     
    FREQUENCY_OPTIONS = [
      ["Please Select the Course Frequency",""],
      ["Every Year","Every Year"],
      ["Every 2 Years","Every 2 Years"]
    ].freeze
   
    FACILITY_OPTIONS = [
      ["Please Select the Facility",""],
      ["Existing Unit Facility","Existing Unit Facility"],
      ["Planned Unit Facility","Planned Unit Facility"],
      ["Generic Mediated Classroom","Generic Mediated Classroom"],
      ["Requested New Facility With Specialty Needs","Requested New Facility With Specialty Needs"]
    ].freeze
     
    RESERVED_SEATS_OPTIONS = [
      ["Please Select the Percentage of Seats Open for Digital Culture Students",0],
      ["100%",100],
      ["67%",67]
    ].freeze
  	
  	SPECIAL_NEEDS_OPTIONS = [
  	  ["Please Select the Special Needs Option", ""],
  	  ["Media Computing Studio - 15", "Media Computing Studio - 15"],
  	  ["Fabrication Studio - 25", "Fabrication Studio - 25"],
  	  ["Reconfigurable DC Room- 100", "Reconfigurable DC Room- 100"],
  	  ["Reconfigurable DC Room- 50", "Reconfigurable DC Room- 50"],
      ["Reconfigurable DC Room- 25", "Reconfigurable DC Room- 25"]
  	].freeze
  
    SPECIAL_NEEDS_OPTION_LIST = ["","Media Computing Studio - 15","Fabrication Studio - 25","Reconfigurable DC Room- 100","Reconfigurable DC Room- 50","Reconfigurable DC Room- 25"]
  	CLASSIFICATION_OPTION_LIST = ["","Technological-Humanistic","Humanistic-Technological","Equally Technological and Humanistic"]
    FREQUENCY_OPTION_LIST = ["","Every Year","Every 2 Years"]
    FACILITY_OPTION_LIST = ["","Existing Unit Facility","Planned Unit Facility","Generic Mediated Classroom","Requested New facility With Specialty Needs"]
    RESERVED_SEATS_OPTION_LIST = [0,50,25]
    
    
    def self.paginate_search( search_text, per_page, page, order )
      search = ''
      unless search_text.nil? or search_text.empty?
        search += sanitize_sql_array(['courses.title like ?', "%#{search_text}%"])
        search += sanitize_sql_array([' OR courses.prefix like ?', "%#{search_text}%"])
        search += sanitize_sql_array([' OR courses.number like ?', "%#{search_text}%"])
      end
      @courses = Course.paginate(:conditions => search, :per_page => per_page, :page => page, :order => order)
    end
    
    def self.courses_at_level_by_proficiency( level, page, prof )
      list = Course.find(:all, :conditions => "number >= '#{level}' AND number <= '#{level+99}'", :order => 'prefix, number')
      list.sort! { |x,y|
        if x.outgoing_proficiencies.include?(prof) 
          x_has_prof = true 
        else 
          x_has_prof = false 
        end
        if y.outgoing_proficiencies.include?(prof) 
          y_has_prof = true 
        else 
          y_has_prof = false 
        end
        if x_has_prof and y_has_prof
          x.shortname <=> y.shortname
        elsif x_has_prof
          -1
        elsif y_has_prof
          1
        else
          x.shortname <=> y.shortname
        end
      }
      list
    end
    
    #
    # level is expected to be something like: 100
    # return all courses at a certain level - for example all "100s"
    def self.courses_at_level( level, page, prof = nil )
      if prof.nil?
        Course.paginate(:all, :conditions => "number >= '#{level}' AND number <= '#{level+99}'", :per_page => 8, :page => page, :order => 'prefix, number')
      else
        wplist = WillPaginate::Collection.create(page, 8) do |pager|        
          list = Course.courses_at_level_by_proficiency(level,page,prof)
          #n = list.size
          start = (page.to_i-1)*8
          # inject the result array into the paginated collection:
          pager.replace(list[start, 8])
          unless pager.total_entries
            # the pager didn't manage to guess the total count, do it manually
            n = Course.count(:all, :conditions => "number >= '#{level}' AND number <= '#{level+99}'", :order => 'prefix, number')
            pager.total_entries = n
          end
        end
      end
    end
    
    def shortname
      prefix + ' ' + number.to_s
    end
      
    def fullname
      prefix + ' ' + number.to_s + ' - ' + title
    end
    
    def shortname_with_id
      shortname + ' (' + id.to_s + ')'
    end
    
    def level
      (number / 100).floor * 100
    end
    
    def incoming_proficiencies
      proficiencies.find(:all, :conditions => "course_proficiencies.proficiency_direction = 'Incoming'", :order => 'name, level')
    end
    
    def outgoing_proficiencies
      proficiencies.find(:all, :conditions => "course_proficiencies.proficiency_direction = 'Outgoing'", :order => 'name, level')
    end
    
    def incoming_proficiencies_for_slot( s )
      proficiencies.find(:all, :conditions => "course_proficiencies.proficiency_direction = 'Incoming' AND course_proficiencies.slot = '#{s}'", :order => 'name, level')
    end
    
    def add_incoming_proficiency( prof, slot )
      CourseProficiency.create_course_proficiency('Incoming', id, prof.id, slot)
    end
    
    def add_outgoing_proficiency( prof )
      CourseProficiency.create_course_proficiency('Outgoing', id, prof.id, nil)
    end
    
    def is_slot_possible?( s )
      is_it_possible = true
      incoming_proficiencies_for_slot(s).each do |prof|
        is_it_possible = false if prof.courses_with_output.size == 0
      end
      is_it_possible
    end
    
    # 
    # return an array, each element is an array of proficiencies from a slot.
    # no empty elements, if a slot doesn't have any proficiencies, it is skipped.
    # so if there are not proficiencies in any slots, the returned array will be empty.
    def incoming_proficiency_arrays
      results = []
      1.upto 5 do |i|
        slot = incoming_proficiencies_for_slot(i)
        unless slot.nil? or slot.empty?
          results.push(slot)
        end
      end
      results
    end
    
    
    def outgoing_proficiency_string
      outgoing_proficiencies.join(', ')
    end

    def incoming_proficiency_string
      result = ""
      incoming_proficiency_arrays.each do |plist|
        if plist.length > 1
          result += ' OR ' unless result.empty?
          result += '(' + plist.join(' AND ') + ')'
        elsif plist.length == 1
          result += ' OR ' unless result.empty?
          result += plist[0].fullname
        end
      end
      result
    end
    
    def incoming_proficiency_string_with_counts
      result = ""
      incoming_proficiency_arrays.each do |plist|
        if plist.length > 1
          result += ' OR ' unless result.empty?
          clist = plist.map { |item| item.fullname + '[' + item.courses_with_output.size.to_s + ']'  }
          result += '(' + clist.join(' AND ') + ')'
        elsif plist.length == 1
          result += ' OR ' unless result.empty?
          result += plist[0].fullname + '[' + plist[0].courses_with_output.size.to_s + ']'
        end
      end
      result
    end
   
    def proficiency_exists?( proficiency )
      proficiency == self.proficiencies.find(:first, :conditions => "course_proficiencies.proficiency_id = '#{proficiency.id}'")
    end
    
    def can_add_in_proficiency?( proficiency )
      if self.level > 100
        proficiency.level==(self.level-100)
      else
        false
      end
    end
    
    def can_add_out_proficiency?( proficiency )
      proficiency.level==self.level
    end
    
    def reached_out_proficiency_limit?
      self.outgoing_proficiencies.length == 5
    end
    
    def reached_in_proficiency_limit_for_slot?( slot )
      self.incoming_proficiencies_for_slot(slot).length > 4
    end
    
    # returns the number of the higest slot that has something in it.
    def highest_slot_filled
      course_proficiencies = self.course_proficiencies.find(:all, :conditions => "proficiency_direction = 'Incoming'")
      n = 0
      course_proficiencies.each do |cp|
        unless cp.slot.nil?
          n = cp.slot if cp.slot > n
        end
      end
      return n
    end
    
    def start_date_as_semester_string
      if anticipated_start_date.nil?
        return ' '
      end
      Semester.semester_for_month(self.anticipated_start_date.month()) + ' ' +  self.anticipated_start_date.year().to_s
    end
    
    def average_rating
      self.reviews.average("rating")
    end
    
    def to_s
      self.fullname
    end
    
      
        
end


