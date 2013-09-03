require "capistrano-unicorn"

# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

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
end

after "deploy:restart", "unicorn:reload" # app IS NOT preloaded
