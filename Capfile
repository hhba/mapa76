load 'deploy'

# Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

require "bundler/capistrano"
set :bundle_flags, "--deployment --quiet --binstubs"

set :application, "mapa76"

set :user, "deployer"
set :domain, "184.173.160.186"
set :environment, "production"
set :deploy_to, "/home/deployer/apps/#{application}"
set :scm, :git
set :repository, "git://github.com/hhba/mapa76.git"
set :branch, "master"
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, :forward_agent => true
set :keep_releases, 5

set :config_files, %w{ mongoid elasticsearch resque monit workers }

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

role :app, domain
role :web, domain
role :workers, domain
role :db, domain, :primary => true

namespace :deploy do
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
    run "ln -nfs #{deploy_to}/shared/config/monit.conf #{release_path}/config/monit.conf"
    run "ln -nfs #{deploy_to}/shared/thumbs #{release_path}/public/thumbs"
  end
  after "deploy:update_code", "deploy:create_symlink_shared"

  task :migrate do
    puts "No migrations"
  end
end

after "deploy", "deploy:cleanup" # keep only the last 5 releases

load 'aphrodite/config/deploy'
load 'hephaestus/config/deploy'

=begin
def rake(task)
  run "cd #{current_path} && APP_ENV=production bundle exec rake #{task} --trace"
end
=end
