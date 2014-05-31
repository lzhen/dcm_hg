class Path < ActiveRecord::Base
  
  belongs_to :student, :class_name => "User", :foreign_key => "student_id"
  
  has_many :path_instances, :dependent => :destroy
  has_many :instances, :through => :path_instances
  
  has_many :path_external_instances, :dependent => :destroy
  has_many :external_instances, :through => :path_external_instances

  validates_presence_of :title, :student_id
  
  # is a path completely empty? considers courses and external_courses
  def empty?
    self.instances.empty? and self.external_instances.empty?
  end
  
  def instance_for_course_in_path( a_course )
    a_class = instances.find(:first, :conditions => "course_id = '#{a_course.id}'")
  end
  
  # checks if the course already exists in the path
  def course_exists?( a_course )
    a_class = instance_for_course_in_path( a_course )
    return false if a_class.nil?
    true
  end
  
  # checks if the class already exists in the path
  def class_exists?( a_class )
    self.instances.exists?(:course_id => a_class.course_id)
    #c = self.instances.find(:first, :conditions => "instances.course_id = '#{a_class.course_id}'")
    #return false if c.nil? 
    #true
  end
  
  def semester_class_is_in_path( a_class )
    c = self.instances.find(:first, :conditions => "instances.course_id = '#{a_class.course_id}'")
    if c.nil?
      return nil
    else
      return c.semester
    end
  end
  
  def dc_credit_hours_in_path
    #
    # TODO: this is hackish! there should be formal way to identify the categories same as
    # "Major Map" documentation from Erica identifies them. (Should be part of database, not code)
    excluded_courses = ['ENG 102', 'ENG 105', 'ENG 108', 'MAT 117', 'MAT 170', 'MAT 210']
    
    credit_hours = 0
    instances.each do |i|
      unless excluded_courses.include?(i.course.shortname)
        credit_hours += i.course.credit_hours
      end
    end
    credit_hours
  end
  
  def list_of_instances_in_path
    path_classes = self.instances
    #Hash map for semesters and classes in them
    path_semesters = Hash.new(1)
    path_classes.each do |c|
      if path_semesters.has_key?(c.semester_id)
        path_semesters[c.semester_id] << c
      else
        path_semesters[c.semester_id] = [c]
      end
    end
    self.external_instances.each do |c|
      if path_semesters.has_key?(c.semester_id)
        path_semesters[c.semester_id] << c
      else
        path_semesters[c.semester_id] = [c]
      end
    end
    path_semesters_sorted = path_semesters.sort
  end
  
  #returns all proficiencies acquired in path
  def list_of_proficiencies
    collected_profs = []
    @path_semesters_sorted = list_of_instances_in_path
    @path_semesters_sorted.each do |value|
    
      #go through each class
      value[1].each do |a_class|
        #collected_profs = collected_profs + a_class.course.outgoing_proficiencies unless a_class.course.outgoing_proficiencies.nil?
        if a_class.class == Instance
          unless a_class.course.outgoing_proficiencies.nil?
            #add lower level proficiencies if only higher level proficiency is collected
            # eg: if user has Content Analysis 300 but not Content Analysis 200 and 100, then add those as well.
            a_class.course.outgoing_proficiencies.each do |op|
              plist = Proficiency.find(:all, :conditions => ["name = ? and level <= ?", op.name, op.level])
              plist.each do |p|
                collected_profs << p unless collected_profs.include?(p)
              end
            end
          end
        else
          # this is an external coure
          a_class.external_course.proficiencies.each do |op|
            plist = Proficiency.find(:all, :conditions => ["name = ? and level <= ?", op.name, op.level])
            plist.each do |p|
              collected_profs << p unless collected_profs.include?(p)
            end
          end
        end
      end
    end
    
    collected_profs.uniq!
    collected_profs
  end
  
  #returns proficiencies acquired in semesters prior to the course offering selected
  def list_of_proficiencies_in_path_for_class( a_class )
    collected_profs = []
    #go through each semester in path
    #puts "paths semesters sorted"
    #puts @path_semesters_sorted
    @path_semesters_sorted.each {|value|
      s = Semester.find(value[0])
      logger.debug("check semester #{s.fullname}")
      if ( a_class.semester_id > s.id ) #if semester is prior to the current class' semester
        #go through each class
        value[1].each { |c|
          #proficiencies of just one level below need to be considered
          #so check if course is just one level below instance
          #if so then add outgoing proficiency of that course to collected_profs
          
          # i _think_ it was wrong to check only one level below
          # look at all courses...
          #if c.course.level == (a_class.course.level-100)
          #  for p in c.course.outgoing_proficiencies
          #    collected_profs << p
          #  end
          #end
          
          #logger.debug( "look at class: " + c.course.shortname )
          
          #collected_profs = collected_profs + c.course.outgoing_proficiencies unless c.course.outgoing_proficiencies.nil?
          if c.class == Instance
            unless c.course.outgoing_proficiencies.nil?
              #add lower level proficiencies if only higher level proficiency is collected
              # eg: if user has Content Analysis 300 but not Content Analysis 200 and 100, then add those as well.
              c.course.outgoing_proficiencies.each do |op|
                plist = Proficiency.find(:all, :conditions => ["name = ? and level <= ?", op.name, op.level])
                plist.each do |p|
                  collected_profs << p unless collected_profs.include?(p)
                end
              end
            end
          else
            # this is an external coure
            c.external_course.proficiencies.each do |op|
              plist = Proficiency.find(:all, :conditions => ["name = ? and level <= ?", op.name, op.level])
              plist.each do |p|
                collected_profs << p unless collected_profs.include?(p)
              end
            end
          end 
        }
      else
        break
      end
    }
    
    logger.debug( "proficiencies in path:" )
    collected_profs.each do |p| logger.debug "   " + p.fullname end
    
    
    #need to consider courses in list of completed courses as well
    collected_profs = collected_profs + self.student.collected_proficiencies unless self.student.collected_proficiencies.nil?
    collected_profs.uniq!
    logger.debug( "proficiencies in path along with completed course proficiencies:" )
    collected_profs.each do |p| logger.debug "   " + p.fullname end
    collected_profs
  end
  
  #checks if the path has the required incoming proficiencies to take up the class (course)
  def has_required_proficiencies( a_class )
    #
    # if its specialized, we just let it thru
    #return true unless a_class.course.is_general
    
    #
    # currently, there aren't proficiencies below 100, so
    # if its a 100 course, we just let it thru
    return true if a_class.course.level == 100
    
    @path_semesters_sorted = list_of_instances_in_path
    proficiencies = list_of_proficiencies_in_path_for_class( a_class )
    
    max_slot = a_class.course.highest_slot_filled
    # if max_slot is 0, there are no incoming_proficiencies!!!
    return true if max_slot == 0
    
    logger.debug( "proficiencies in path:" )
    proficiencies.each do |p| logger.debug "   " + p.fullname end
    
    1.upto max_slot do |i|
      required_profs = a_class.course.incoming_proficiencies_for_slot(i)
      slot_requirements_met = true
      required_profs.each do |p|
        slot_requirements_met = false unless proficiencies.include?(p)
        logger.debug "missing : " + p.fullname unless proficiencies.include?(p)
      end
      return true if slot_requirements_met
    end
    false
  end
  
  #def can_add_previous_course? ( course )
  #  not self.student.user_courses.exists?(:course_id => course)
  #end
  
  def previous_course_exists? ( course )
    self.student.user_courses.exists?(:course_id => course)
  end
  
  def self.create_path( user, title )
    
    path = Path.new( { :student_id => user.id, :title => title } )
    
    if path.save!
      path.reload
      if user.paths.size == 1
        user.update_attribute(:current_path, path.id)
      end
      return path
    else
      puts "record not saved"
    end
    nil
  end
  
  # return a sorted hash (nested array, see Hash#sort), keys in the hash are semesters, and values are an array of course instances
  def path_dictionary
    path_semesters = Hash.new(1)
    instances.each do |c|
      if path_semesters.has_key?(c.semester_id)
        path_semesters[c.semester_id] << c
      else
        path_semesters[c.semester_id] = [c]
      end
    end
    external_instances.each do |c|
      if path_semesters.has_key?(c.semester_id)
        path_semesters[c.semester_id] << c
      else
        path_semesters[c.semester_id] = [c]
      end
    end
    path_semesters.sort
  end
  
  
  
end
