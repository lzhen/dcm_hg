require 'spec_helper'

module CourseSpecHelper
  def valid_course_attributes
    {
      :title => 'Topics in Digital Culture',
      :prefix => 'AME',
      :number => 101,
      :description => 'Topics in Digital Culture examines the effects of digital technology on the way we live, communicate, learn, and create. It proposes that we are moving towards a hybrid (physical-digital) existence and culture.',
      :credit_hours => 3,
      :is_existing => true,
      :anticipated_start_date => Date.civil(2010,8,15),
      :classification => 'Humanistic-Technological',
      :frequency => 'Every Year',
      :facility_needs => 'Reconfigurable DC Room- 25',
      :total_seats => 25,
      :reserved_seats => 100,
    }
  end
  
  def simple_course
    Course.create!(valid_course_attributes)
  end
  
  def simple_100_course_setup
    @course = Course.create(valid_course_attributes)
    prof1 = Proficiency.create(:name => "Computational Tools", :level => 100)
    prof2 = Proficiency.create(:name => "Sensors and Signals", :level => 100)
    @course.add_outgoing_proficiency(prof1)
    @course.add_outgoing_proficiency(prof2)
  end
  
  def simple_200_course_setup
    @course = Course.create(valid_course_attributes.with(:number => 201))
    prof1 = Proficiency.create(:name => "Computational Tools", :level => 100)
    prof2 = Proficiency.create(:name => "Sensors and Signals", :level => 100)
    prof3 = Proficiency.create(:name => "Form and Composition", :level => 200)
    prof4 = Proficiency.create(:name => "Collaborative Principles", :level => 200)
    @course.add_incoming_proficiency(prof1,1)
    @course.add_incoming_proficiency(prof2,2)
    @course.add_outgoing_proficiency(prof3)
  end
end

describe Course do
  include CourseSpecHelper
  
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    simple_course.should_not be_nil
  end
  
  it "should return a shortname" do
    simple_course.shortname.should == 'AME 101'
  end
  
  it "should return a fullname" do
    simple_course.fullname.should == 'AME 101 - Topics in Digital Culture'
  end
  
  it "should return a level" do
    simple_course.level.should == 100
  end
  
  it "should return a 200 level" do
    Course.create(valid_course_attributes.with(:number => 294)).level.should == 200
  end
  
  it "should not allow a nil prefix" do
    Course.create(valid_course_attributes.with(:prefix => nil)).should have(1).error_on(:prefix)
  end
  
  it "should not allow an empty prefix" do
    Course.create(valid_course_attributes.with(:prefix => '')).should have(1).error_on(:prefix)
  end
  
  it "should not allow a number below 100" do
    Course.create(valid_course_attributes.with(:number => 99)).should have(1).error_on(:number)
  end
  
  it "should not allow a number above 799" do
    Course.create(valid_course_attributes.with(:number => 800)).should have(1).error_on(:number)
  end
  
  it "should return outgoing proficiencies" do
    simple_100_course_setup()
    @course.outgoing_proficiencies.size.should == 2
  end
  
  it "should have no incoming proficiencies with 100 level" do
    simple_100_course_setup()
    @course.incoming_proficiencies.size.should == 0
  end
  
  it "should return incoming proficiencies with 200 level" do
    simple_200_course_setup()
    @course.incoming_proficiencies.size.should == 2
  end
  
  it "should return incoming proficiency string with 200 level" do
    simple_200_course_setup()
    @course.incoming_proficiency_string.should == 'Computational Tools 100 OR Sensors and Signals 100'
  end
  
  it "should return outgoing proficiency string with 100 level" do
    simple_100_course_setup()
    @course.outgoing_proficiency_string.should == 'Computational Tools 100, Sensors and Signals 100'
  end
  
  it "should return outgoing proficiency string with 200 level" do
    simple_200_course_setup()
    @course.outgoing_proficiency_string.should == 'Form and Composition 200'
  end
  
end
