require "capistrano-unicorn"

set :bundle_flags, "--deployment --quiet --binstubs"

server "184.173.160.186", :web, :app, :db, primary: true

set :application, "aphrodite"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/mapa76.info/#{application}"
set :subdir, "aphrodite"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/hhba/mapa76.git"
set :branch, "master"
set :scm_verbose, true
set :ssh_options, :forward_agent => true

set :keep_releases, 5

set :config_files, %w{ mongoid resque elasticsearch }

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

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

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  desc "Symlink config files"
  task :create_symlink_shared do
    config_files.each do |filename|
      run "ln -nfs #{deploy_to}/shared/config/#{filename}.yml #{release_path}/config/#{filename}.yml"
    end
    run "ln -nfs #{deploy_to}/shared/thumbs #{release_path}/public/thumbs"
  end

  task :migrate do
    puts "No migrations"
  end

  desc "Checkout subdirectory and delete all the other stuff"
  task :checkout_subdir do
    run "if [ -h #{current_release} ] ; then rm #{current_release} ; fi"
    run "mv #{current_release}/#{subdir}/ /tmp && rm -rf #{current_release}/* && mv /tmp/#{subdir}/* #{current_release}"
  end

  desc "Create Chaos symlink"
  task :create_chaos_symlink do
    run "ln -nfs #{deploy_to}/../chaos #{current_release}/../chaos"
  end

  before "deploy", "deploy:check_revision"
  before "deploy:finalize_update", "deploy:checkout_subdir"
  before "deploy:finalize_update", "deploy:create_chaos_symlink"
  after "deploy:update_code", "deploy:create_symlink_shared"
  after "deploy:setup", "deploy:setup_config"
  after "deploy:restart", "unicorn:reload" # app IS NOT preloaded
  after "deploy", "deploy:cleanup" # keep only the last 5 releases
end

require "bundler/capistrano"
