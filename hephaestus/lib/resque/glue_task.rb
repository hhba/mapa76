class GlueTask
  @queue = :glue

  def self.perform(document_id)
    document = Document.find(document_id)
    task_finder = TaskFinder.new(document)

    unless task_finder.last_task? and task_finder.current_task_ended?
      klass = Kernel.const_get(task_finder.next_task.split('_').map(&:capitalize).join)
      Resque.enqueue(klass, document_id)
    end
  end
end