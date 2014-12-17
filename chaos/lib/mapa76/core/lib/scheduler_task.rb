class SchedulerTask
  @queue = :default

  # NOTE Analyzers should override this method
  # and reenqueue Document to the first step of the process.
  def self.perform(document_id)
    raise NotImplementedError
  end
end
