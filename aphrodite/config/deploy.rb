require "bundler/capistrano"
require "capistrano-unicorn"

set :bundle_flags, "--deployment --quiet --binstubs"

server "184.173.160.186", :web, :app, :db, primary: true

set :application, "mapa76-webapp"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/hhba/mapa76-webapp.git"
set :branch, "master"
set :scm_verbose, true
set :ssh_options, :forward_agent => true

set :keep_releases, 5

set :config_files, %w{ mongoid resque elasticsearch }

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/thumbs"
    run "mkdir -p #{shared_path}/pids/unicorn"
  end
  after "deploy:setup", "deploy:setup_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  desc "Symlink config files"
  task :create_symlink_shared do
    config_files.each do |filename|
      run "ln -nfs #{deploy_to}/shared/config/#{filename}.yml #{release_path}/config/#{filename}.yml"
    end
    run "ln -nfs #{deploy_to}/shared/thumbs #{release_path}/public/thumbs"
  end
  after "deploy:update_code", "deploy:create_symlink_shared"

  task :migrate do
    puts "No migrations"
  end
end

after "deploy:restart", "unicorn:reload" # app IS NOT preloaded
