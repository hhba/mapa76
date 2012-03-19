$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require 'bundler/capistrano'
require 'rvm/capistrano'

set :application, "alegato"

set :user, "mapa"
set :domain, "hhba.info"
set :environment, "production"
set :deploy_to, "/home/mapa/#{application}"

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :normalize_asset_timestamps, false
set :rvm_ruby_string, '1.9.2@alegato'
set :rvm_type, :user

set :scm, :git
set :repository, "git://github.com/mapa76/alegato.git"
set :branch, "master"
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, :forward_agent => true

set :keep_releases, 5

namespace :deploy do
  desc "symlink to mongoid.yml"
  task :create_symlink_shared do
    run "ln -nfs #{deploy_to}/shared/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{deploy_to}/shared/uploads #{release_path}/public/uploads"
  end

  task :migrate do
    puts "no mgirations"
  end

  desc "restarting"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after 'deploy:update_code', 'deploy:create_symlink_shared'
