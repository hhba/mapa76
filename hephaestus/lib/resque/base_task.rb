require 'json'
require 'active_support/all'

#
# Tasks call the following task, unless @next_task is nil
# The communication between tasks is though JSON as in:
# {
#   'data': ...,
#   'metadata': ...
# }
#

class BaseTask
  def self.perform(input)
    task = self.new(JSON.parse(input))
    task.call
    task.schedule_next
  end

  def self.before_perform(*args)
    logging('start', document_id(*args))
  end

  def self.after_perform(*args)
    logging('finish', document_id(*args))
  end

  def self.on_failure(e, *args)
    logging('failure', document_id(*args))
    logging('failure', e.backtrace.join("\n"))
  end

  def self.logging(msg, args = nil)
    if args
      logger.info "[#{msg}] #{@queue} with #{args}"
    else
      logger.info "[#{msg}] #{@queue} without args"
    end
  end

  def self.document_id(*args)
    begin
      JSON.parse(args[0])['metadata']['document_id']
    rescue NoMethodError
      "NO_DOCUMENT_ID"
    end
  end

  def metadata(options = {})
    @metadata.merge({'current_task' => current_task}).merge(options)
  end

  def current_task
    self.class.to_s.underscore
  end

  def schedule_next
    Resque.enqueue(SchedulerTask, @output.to_json)
  end

  def classify(klass)
    klass.split('_').map(&:capitalize).join.constantize
  end


  def next_task
    self.class.instance_variable_get(:@next_task)
  end
end
