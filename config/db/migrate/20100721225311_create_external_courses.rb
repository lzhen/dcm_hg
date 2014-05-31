class CreateExternalCourses < ActiveRecord::Migration
  def self.up
    create_table :external_courses do |t|
      t.string :title
      t.string :prefix
      t.integer :number

      t.timestamps
    end
    
    ExternalCourse.create( :prefix => 'ARA', :number => 202, :title => 'Understanding Photographs' )
    ExternalCourse.create( :prefix => 'ARA', :number => 498, :title => 'Photography and Language' )
    ExternalCourse.create( :prefix => 'ARS', :number => 102, :title => 'Art from Renaissance to Present' )
    ExternalCourse.create( :prefix => 'ARS', :number => 250, :title => 'History of Photography' )
    ExternalCourse.create( :prefix => 'ARS', :number => 294, :title => 'Art and Television' )
    ExternalCourse.create( :prefix => 'ARS', :number => 438, :title => 'Art of the 20th Century I' )
    ExternalCourse.create( :prefix => 'ARS', :number => 439, :title => 'Art of the 20th Century II' )
    ExternalCourse.create( :prefix => 'ARS', :number => 460, :title => 'Art Now' )
    ExternalCourse.create( :prefix => 'ARS', :number => 494, :title => '20th Century Art History' )
    ExternalCourse.create( :prefix => 'DAH', :number => 401, :title => 'Dance History' )
    ExternalCourse.create( :prefix => 'IAP', :number => 305, :title => '20th/21st Century Art, Media, Technology and Performance' )
    ExternalCourse.create( :prefix => 'MHL', :number => 440, :title => 'Music Since 1900' )
    ExternalCourse.create( :prefix => 'MHL', :number => 494, :title => '20th Century Music History' )
    ExternalCourse.create( :prefix => 'THE', :number => 320, :title => 'History of Theatre I' )
    ExternalCourse.create( :prefix => 'THE', :number => 321, :title => 'History of Theatre II' )
    ExternalCourse.create( :prefix => 'THE', :number => 322, :title => 'Theatre History and Culture' )
    ExternalCourse.create( :prefix => 'THE', :number => 403, :title => 'Independent Film' )
    ExternalCourse.create( :prefix => 'THE', :number => 404, :title => 'Foreign Film' )
    ExternalCourse.create( :prefix => 'THE', :number => 405, :title => 'Film Great Performers and Directors' )
    ExternalCourse.create( :prefix => 'THE', :number => 494, :title => '20th Century Theatre History' )
    ExternalCourse.create( :prefix => 'THP', :number => 482, :title => 'Theatre for Social Change' )
    
    ExternalCourse.create( :prefix => 'ALA', :number => 100, :title => 'Introduction to Environmental Design' )
    ExternalCourse.create( :prefix => 'ALA', :number => 102, :title => 'Architecture, Landscape Architecture, and Society' )
    ExternalCourse.create( :prefix => 'ALA', :number => 294, :title => 'Sustainability in the Built Environment' )
    ExternalCourse.create( :prefix => 'APH', :number => 213, :title => 'History of Architecture I' )
    ExternalCourse.create( :prefix => 'APH', :number => 214, :title => 'History of Architecture II' )
    ExternalCourse.create( :prefix => 'APH', :number => 300, :title => 'World Architecture/Western Cultures' )
    ExternalCourse.create( :prefix => 'APH', :number => 336, :title => '20th Century Architecture I' )
    ExternalCourse.create( :prefix => 'APH', :number => 337, :title => '20th Century Architecture II' )
    ExternalCourse.create( :prefix => 'DSC', :number => 101, :title => 'Design Awareness' )
    ExternalCourse.create( :prefix => 'GRA', :number => 394, :title => 'Graphic Design History I' )
    ExternalCourse.create( :prefix => 'GRA', :number => 395, :title => 'Graphic Design History II' )
    ExternalCourse.create( :prefix => 'IND', :number => 316, :title => '20th Century Design I' )
    ExternalCourse.create( :prefix => 'IND', :number => 317, :title => '20th Century Design II' )
    ExternalCourse.create( :prefix => 'INT', :number => 111, :title => 'Interior Design Issues and Theories' )
    ExternalCourse.create( :prefix => 'INT', :number => 310, :title => 'Interior Design History I' )
    ExternalCourse.create( :prefix => 'IND', :number => 311, :title => 'Interior Design History II' )
    ExternalCourse.create( :prefix => 'LPH', :number => 210, :title => 'History of Landscape Architecture' )
    ExternalCourse.create( :prefix => 'LPH', :number => 211, :title => 'Contemporary Landscape Architecture' )
  end

  def self.down
    drop_table :external_courses
  end
end
