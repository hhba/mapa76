set :stages, %w(stating aphrodite hephaestus)
set :user, "deploy"
require 'capistrano/ext/multistage'

set :application, "chaos"
set :deploy_to, "/home/#{user}/apps/mapa76.info/#{application}"
set :subdir, "chaos"
set :deploy_via, :remote_cache
set :use_sudo, false

set :repository,  "git://github.com/hhba/mapa76.git"
set :scm, :git
set :scm_verbose, true
set :normalize_asset_timestamps, false

set :ssh_options, :forward_agent => true
set :keep_releases, 5

namespace :deploy do
  desc "Checkout subdirectory and delete all the other stuff"
  task :checkout_subdir do
    run "mv #{current_release}/#{subdir}/ /tmp && rm -rf #{current_release}/* && mv /tmp/#{subdir}/* #{current_release}"
  end

  before "deploy:finalize_update", "deploy:checkout_subdir"
  after "deploy:restart", "deploy:cleanup"
end

require "bundler/capistrano"
