server '191.237.72.87', :web, :app, :workers, :db, primary: true
set :branch, "master"

set :ssh_options, {
  auth_methods: ["publickey"],
  keys: ["~/.ssh/myPrivateKey.key"],
  port: 22
}
