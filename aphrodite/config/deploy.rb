require "capistrano-unicorn"

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :bundle_flags, "--deployment --quiet --binstubs"

set :application, "aphrodite"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/mapa76.info/#{application}"
set :subdir, "aphrodite"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/hhba/mapa76.git"
set :scm_verbose, true
set :ssh_options, :forward_agent => true

set :keep_releases, 5

set :config_files, %w{ application mongoid resque elasticsearch }

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill `cat #{shared_path}/pids/unicorn/pid`"
    run "service unicorn_aphrodite start"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "service unicorn_aphrodite start"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill `cat #{shared_path}/pids/unicorn/pid`"
  end

  task :setup_config, roles: :app do
    # sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/thumbs"
    run "mkdir -p #{shared_path}/pids/unicorn"
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

  desc "Link aeolus app"
  task :link_aeolus do
    run "mkdir -p #{current_release}/app/assets/javascripts/aeolus/"
    run "ln -sf /home/deployer/apps/mapa76.info/aeolus/js/vendor.js #{current_release}/app/assets/javascripts/aeolus/vendor.js"
    run "ln -sf /home/deployer/apps/mapa76.info/aeolus/js/app.js #{current_release}/app/assets/javascripts/aeolus/app.js"
  end

  before "deploy", "deploy:check_revision"
  before "deploy:finalize_update", "deploy:checkout_subdir"
  before "deploy:finalize_update", "deploy:change_chaos_dependency"
  before "deploy:assets:precompile", "deploy:link_aeolus"
  after "deploy:update_code", "deploy:create_symlink_shared"
  after "deploy:setup", "deploy:setup_config"
  after "deploy", "deploy:cleanup" # keep only the last 5 releases
end

require "bundler/capistrano"
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
