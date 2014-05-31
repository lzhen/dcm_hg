class Proficiency < ActiveRecord::Base
  
  has_many :course_proficiencies, :dependent => :destroy
  has_many :courses, :through => :course_proficiencies, :select => "course_proficiencies.proficiency_direction, courses.*"
  
  validates_presence_of :name
  
  LEVEL_OPTIONS = [
	  ["Please Select the Proficiency Level",0],
	  ["100",100],
	  ["200",200],
	  ["300",300],
	  ["400",400]
	].freeze
	
	LEVEL_OPTION_LIST = ["","100","200","300","400"]
  
  def self.search_for_courses( proficiency, proficiency_direction )
	  if ( proficiency_direction == nil )
	    proficiency.courses.find(:all, :order => 'name' )
	  else
	    proficiency.courses.find( :all, :conditions => [ "proficiency_direction = ?", proficiency_direction ], :order => 'name' )
	  end
	end
  
  def fullname
    name + " " + level.to_s
  end
  
  def self.search_fullnames_for_auto_complete(search,course_level,direction)
    if ( direction == "Incoming" )
      level = course_level.to_i - 100
    else
      level = course_level
    end
    list = Proficiency.find( :all, :conditions => "proficiencies.name like '#{search}%' AND proficiencies.level = '#{level}'", :order => 'name')
 
    return_list = []
    list.each do |u|
      return_list <<  u.fullname
    end
    return_list
  end
  
  def self.search_by_fullname(search)
   tokens = search.split(" ")
   level = tokens[(tokens.length) - 1]
   name = tokens[0]
   tokens.each_index { |x|
     if ( ( x < (tokens.length - 1)) && (x > 0) )
       name = name + " " + tokens[x]
     end
   }
   proficiency = Proficiency.find(:first, :conditions => "name = '#{name}' AND level = '#{level}'", :order => 'name' )
  end
  
  # rename proficiencies (all levels) that have the name src to dst
  # (created for migration needed due to changes in proficiencies)
  def self.rename(src,dst)
    list = Proficiency.find(:all, :conditions => "name = '#{src}'")
    list.each do |p|
      unless p.update_attributes( :name => dst )
        puts "rename error, unable to update_attributes #{src} -> #{dst} (level = #{p.level})"
      end
    end
  end
  
  # find all ingoing and outgoing proficiencies connections for src (at all levels!),
  # and move them to another proficiency named dst
  # (created for migration needed due to changes in proficiencies)
  def self.move(src,dst)
    puts
    puts "*** MOVE #{src} -> #{dst} ***"
    puts
    src_list = Proficiency.find(:all, :conditions => "name = '#{src}'")
    src_list.each do |src_p|
      dst_p = Proficiency.find(:first, :conditions => "name = '#{dst}' and level = '#{src_p.level}'")
      puts "Warning, destination proficiency is nil - didn't find #{dst}" if dst_p.nil?
      Proficiency.move_outgoing_connections(src_p,dst_p)
      Proficiency.move_incoming_connections(src_p,dst_p)
    end
  end
  
  def self.move_outgoing_connections(src_p,dst_p)
    return nil if src_p.nil?
    return nil if dst_p.nil?
    puts "move outgoing from #{src_p.fullname} to #{dst_p.fullname}"
    list = src_p.course_proficiencies.find(:all, :conditions => "proficiency_direction = 'Outgoing'")
    list.each do |cp|
      puts "found #{cp.course.shortname} with out prof #{src_p.fullname}, change to #{dst_p.fullname}"
      existing_cp = cp.course.course_proficiencies.find(:first, :conditions => "proficiency_id = '#{dst_p.id}' and proficiency_direction = 'Outgoing'")
      if existing_cp.nil?
        unless cp.update_attributes(:proficiency_id => dst_p.id)
          puts "move outgoing error, unable to update_attributes"
        end
      else
        puts "course already has proficiency #{dst_p.name}"
        CourseProficiency.destroy(cp.id)
      end
    end
  end
  
  def self.move_incoming_connections(src_p,dst_p)
    return nil if src_p.nil?
    return nil if dst_p.nil?
    puts "move incoming from #{src_p.fullname} to #{dst_p.fullname}"
    list = src_p.course_proficiencies.find(:all, :conditions => "proficiency_direction = 'Incoming'")
    list.each do |cp|
      puts "found #{cp.course.shortname} with in prof #{src_p.fullname} [slot #{cp.slot}], change to #{dst_p.fullname}"
      existing_cp = cp.course.course_proficiencies.find(:first, :conditions => "proficiency_id = '#{dst_p.id}' and proficiency_direction = 'Incoming' and slot = '#{cp.slot}'")
      if existing_cp.nil?
        unless cp.update_attributes(:proficiency_id => dst_p.id)
          puts "move incoming error, unable to update_attributes"
        end
      else
        puts "course already has proficiency #{dst_p.name} in slot #{cp.slot}"
        CourseProficiency.destroy(cp.id)
      end
    end
  end
  
  # destroy proficiencies with name src (all levels)
  # (created for migration needed due to changes in proficiencies)
  def self.destroy_by_name(src)
    src_list = Proficiency.find(:all, :conditions => "name = '#{src}'")
    Proficiency.destroy(src_list.collect {|item| item.id})
  end

  def to_s
   fullname
  end

  # return an array with all courses that have this proficiency as an outgoing proficiency.
  def courses_with_output
    #courses.find( :all, :conditions => "proficiency_direction='Outgoing'" )
    plist = Proficiency.find(:all, :conditions => "name = '#{name}' AND level >= '#{level}'" )
    clist = []
    plist.each do |p|
      clist += p.courses.find( :all, :conditions => "proficiency_direction='Outgoing'" )
    end
    clist.uniq
  end

  def courses_with_input
   courses.find( :all, :conditions => "proficiency_direction='Incoming'" ).uniq
  end
  
  def slots_with_input
    courses.find( :all, :conditions => "proficiency_direction='Incoming'" )
  end
   
end
