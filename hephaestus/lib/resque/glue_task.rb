class GlueTask < LoggedJob
  @queue = :glue

  def self.perform(document_id)
    document = Document.find(document_id)
    task_finder = TaskFinder.new(document)
    unless task_finder.last_task? and task_finder.current_task_ended?
      Resque.enqueue(task_finder.next_task)
    end
  end
end
