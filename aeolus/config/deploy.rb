set :application, 'aeolus'
set :stages, %w(production staging)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :repository, './dist'
set :scm, :none
set :deploy_via, :copy
set :use_sudo, false
set :copy_compression, :gzip
set :user, 'deployer'
set :deploy_to, "/home/#{user}/apps/mapa76.info/#{application}"
set :copy_remote_dir, "/home/#{user}/apps/mapa76.info/#{application}"

namespace :deploy do
  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with aeolus"
    task t, :roles => :app do ; end
  end

  desc 'Generate server ready files'
  task :grunt do
    %x(grunt #{grunt_command})
  end
end

before "deploy:update", "deploy:grunt"
