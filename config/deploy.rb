# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion


#require "bundler/capistrano"

set :use_sudo, true

role :web, "digitalculture.asu.edu"
role :app, "digitalculture.asu.edu"
role :db,  "digitalculture.asu.edu", :primary => true

set :application, "dcm"
set :scm, :mercurial
set :repository, "ssh://capistrano@ame3.asu.edu//hg/#{application}-hg"
set :scm_user, "capistrano"
set :scm_command, "/usr/local/bin/hg"
#set :scm_username, "capistrano"
#set :scm_command, "/usr/local/bin/svn"


set :deploy_to, "/usr/local/apps/#{application}" # defaults to "/u/apps/#{application}"
set :user, "dcuser"            # defaults to the currently logged in user

# Use the mongrel recipes from the mongrel_cluster gem
#require 'mongrel_cluster/recipes'
#set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
#set :mongrel_clean, true





desc "after_update"
task :after_update_code do
  
    run "cp #{release_path}/public/flash/vp_config_production.xml #{release_path}/public/flash/vp_config.xml"
    
    # this is lame???
    run "cp #{release_path}/config/database.sample #{release_path}/config/database.yml"
    
    # this is a hack work around! why is svn stomping on execute perms in the first place???
    #run "cd #{current_path}/script && chmod +rx ferret_server"
    
    # ferret index
    #run "ln -s /usr/local/apps/#{application}/shared/index #{release_path}/index"
end

#
# make ferret stop/start
#
default_run_options[:shell] = false

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end


