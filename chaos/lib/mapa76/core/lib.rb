autoload :Finder, "mapa76/core/lib/finder"
autoload :TimeSetter, "mapa76/core/lib/time_setter"
autoload :SchedulerTask, "mapa76/core/lib/scheduler_task"

require "mongoid"
require "resque"

module Mongoid
  autoload :References, "mapa76/core/lib/mongoid/references"
end
