require "bundler/capistrano"
require "rvm/capistrano"

set :application, "mapa76"

set :user, "mapa"
set :domain, "hhba.info"
set :workers, "ec2-23-22-65-238.compute-1.amazonaws.com"
set :environment, "production"
set :deploy_to, "/home/mapa/#{application}"

role :app, domain, workers
role :web, domain
role :db, domain, :primary => true

set :normalize_asset_timestamps, false
set :rvm_ruby_string, '1.9.3-p194@mapa76'
set :rvm_type, :user

set :scm, :git
set :repository, "git://github.com/hhba/mapa76.git"
set :branch, "develop"
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, :forward_agent => true

set :keep_releases, 5

set :config_files, %w{ mongoid resque monit workers }


namespace :deploy do
  desc "symlink to mongoid.yml"
  task :create_symlink_shared do
    config_files.each do |filename|
      run "ln -nfs #{deploy_to}/shared/config/#{filename}.yml #{release_path}/config/#{filename}.yml"
    end
    run "ln -nfs #{deploy_to}/shared/uploads #{release_path}/public/uploads"
    run "ln -nfs #{deploy_to}/shared/thumbs #{release_path}/public/thumbs"
  end

  task :migrate do
    puts "no migrations"
  end

  desc "restarting"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :monit do
  desc "Start Monit daemon (rebuilding config file)"
  task :start, :roles => :app do
    rake "monit:start"
  end

  desc "Stop Monit daemon"
  task :stop, :roles => :app do
    rake "monit:stop"
  end

  desc "Restart Monit daemon (rebuilding config file)"
  task :restart, :roles => :app do
    rake "monit:restart"
  end

  desc "Generate *only* Monit configuration file"
  task :config, :roles => :app do
    rake "monit:config"
  end
end

namespace :workers do
  desc "Gracefully reload workers (waits for jobs to finish, then restarts processes)"
  task :reload, :roles => :workers do
    rake "workers:reload"
  end

  desc "Immediately kill workers, cancelling any current job and re-enqueuing them"
  task :stop, :roles => :workers do
    rake "workers:stop"
  end

  desc "Pause all workers (stop processing new jobs)"
  task :pause, :roles => :workers do
    rake "workers:pause"
  end

  desc "Resume all workers (begin processing new jobs)"
  task :resume, :roles => :workers do
    rake "workers:resume"
  end
end

after "deploy:update_code", "deploy:create_symlink_shared"
after "deploy", "workers:reload"

def rake(task)
  run "cd #{current_path} && PADRINO_ENV=production bundle exec rake #{task} --trace"
end
