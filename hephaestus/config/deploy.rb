set :normalize_asset_timestamps, false

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

after "deploy", "workers:reload"
#after "deploy", "mi:create_indexes"
