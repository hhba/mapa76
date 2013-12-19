load "deploy"
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
set :environment, "production"

set :application, "hephaestus"
set :user, "deployer"

set :scm, :git
set :repository, "git://github.com/hhba/mapa76.git"

set :deploy_to, "/home/deployer/apps/mapa76.info/#{application}"
set :app_env, 'production'

set :subdir, "hephaestus"
set :normalize_asset_timestamps, false

set :scm_verbose, true
set :use_sudo, false
set :ssh_options, :forward_agent => true

set :keep_releases, 5

set :config_files, %w{ mongoid elasticsearch resque monit workers }

set :bundle_flags, "--quiet --binstubs"

namespace :deploy do
  desc "Symlink config files"
  task :create_symlink_shared do
    config_files.each do |filename|
      run "ln -nfs #{deploy_to}/shared/config/#{filename}.yml #{release_path}/config/#{filename}.yml"
    end
    run "ln -nfs #{deploy_to}/shared/config/monit.conf #{release_path}/config/monit.conf"
  end

  task :migrate do
    puts "No migrations"
  end

  desc "Checkout subdirectory and delete all the other stuff"
  task :checkout_subdir do
    run "if [ -d /tmp/#{subdir} ]; then rm -rf /tmp/#{subdir}; fi"
    run "mv #{current_release}/#{subdir}/ /tmp && rm -rf #{current_release}/* && mv /tmp/#{subdir}/* #{current_release}"
  end

  desc "Add Chaos as a dependency on Gemfile"
  task :change_chaos_dependency do
    new_chaos_dir = '/home/deployer/apps/mapa76.info/chaos/current'.gsub("/", "\\/")
    gemfile = "#{current_release}/Gemfile"
    gemfile_lock = "#{current_release}/Gemfile.lock"
    run 'sed -i "s/..\/chaos/' + new_chaos_dir + '/" ' + gemfile
    run 'sed -i "s/..\/chaos/' + new_chaos_dir + '/" ' + gemfile_lock
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

namespace :mi do
  desc "Create the indexes defined on your Mongoid models"
  task :create_indexes do
    rake "mi:create_indexes"
  end
end

def rake(task)
  run "cd #{current_path} && APP_ENV=production bundle exec rake #{task} --trace"
end

before "deploy:finalize_update", "deploy:checkout_subdir"
before "deploy:finalize_update", "deploy:change_chaos_dependency"
after "deploy:update_code", "deploy:create_symlink_shared"
after "deploy", "workers:reload"

require "bundler/capistrano"
