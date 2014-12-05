server "aphrodite-analiceme.cloudapp.net" , :app, primary: true
set :branch, "master"

set :ssh_options, {
  auth_methods: ["publickey"],
  keys: ["~/.ssh/myPrivateKey.key"]
}
