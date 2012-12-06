load "deploy"

Dir[%w{
  vendor/gems/*/recipes/*.rb
  vendor/plugins/*/recipes/*.rb
}].each { |plugin| load(plugin) }

# Remove this line to skip loading any of the default tasks
load "config/deploy"
