class Semester < ActiveRecord::Base
  
  SEMESTER_OPTIONS = [
    ["Please Select a Semester",""],
    ["Spring","Spring"],
    ["Summer","Summer"],
    ["Fall","Fall"],
    ["Winter","Winter"]
  ].freeze
  
  has_many :instances
  
  validates_presence_of :name#, :start_date, :end_date
  

  def fullname
    name + ' ' + year.to_s
  end
  
  def self.search_fullnames_for_auto_complete(search, first_year=2011)
    list = Semester.find( :all, :conditions => "semesters.name like '#{search}%'")
    return_list = []
    list.each do |u|
      return_list <<  u.fullname unless u.year.to_i < first_year
    end
    return_list
  end

  def self.search_by_fullname(search)
    tokens = search.split(" ")
    name = tokens[0]
    year = tokens[1]
    semester = Semester.find( :first, :conditions => "name = '#{name}' AND year = '#{year}'" )
  end
 
  def self.start_month_for_semester(semester_as_string)
    puts "test"
    semester_months = {
      "Spring" => "1",
      "Summer" => "6",
      "Fall" => "8",
      "Winter" => "12"
    }
    m = semester_months[semester_as_string]
    m = "1" if m.nil?
    m
  end
  
  def self.start_day_for_semester(semester_as_string)
    semester_months = {
      "Spring" => "15",
      "Summer" => "1",
      "Fall" => "15",
      "Winter" => "29"
    }
    d = semester_months[semester_as_string]
    d = "15" if d.nil?
    d
  end
  
  def self.semester_for_month(month_as_integer)
    month_semester = {
      1 => "Spring", 2 => "Spring", 3 => "Spring", 4 => "Spring", 5 => "Spring",
      6 => "Summer", 7 => "Summer", 
      8 => "Fall", 9 => "Fall", 10 => "Fall", 11 => "Fall",
      12 => "Winter"
    }
    s = month_semester[month_as_integer]
    s = "Spring" if s.nil?
    s
  end

     
    
end
