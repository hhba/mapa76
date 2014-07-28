server "107.170.13.39", :web, :app, :workers, :db, primary: true
set :grunt_command, 'prod'
set :user, "deploy"
