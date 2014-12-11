require 'json'


class BaseTask
  def self.before_perform(*args)
    logging('start', document_id(*args))
  end

  def self.after_perform(*args)
    logging('start', document_id(*args))

    Resque.enqueue(SchedulerTask, @output)
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
end
