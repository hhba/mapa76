server "aphrodite-analiceme.cloudapp.net", :web, :app, :db, primary: true
set :branch, "master"
set :user, "deploy"
set :ssh_options, {
  auth_methods: ["publickey"],
  keys: ["~/.ssh/myPrivateKey.key"]
}

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
end
