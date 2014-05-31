class UserMailer < ActionMailer::Base
  helper :application
  
  default :from => "digitalculture@asu.edu"
  
  def send_path_to_advisor(path,path_semesters_sorted)
    @path = path
    @path_semesters_sorted = path_semesters_sorted
    
    @advisor_email = "Erica Green <Erica.G.Green@asu.edu>"
    @student_email = "#{path.student.name} <#{path.student.email}>"
    
    mail(:to => @advisor_email + ', ' + @student_email, :subject => "DC Path for #{path.student.name}", :from => "#{path.student.name} <#{path.student.email}>")  
  end
  
  def send_request(issue)
    @issue = issue
    
    @help_email = "Cheryl Braciszewski <cheryl.braciszewski@asu.edu>"
    mail(:to => @help_email, :subject => "DC Request: #{issue.subject}", :from => "#{issue.user.name} <#{issue.user.email}>")
  end
    
end
