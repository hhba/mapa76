server "191.237.72.87" , :app, primary: true
set :branch, "master"

set :ssh_options, {
  auth_methods: ["publickey"],
  keys: ["~/.ssh/myPrivateKey.key"],
  port: 63888
}
