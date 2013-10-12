class DocumentProcessBootstrapTask
  @queue = :document_process_bootstrap

  def self.perform(document_id)
    document = Document.find(document_id)
    task_finder = TaskFinder.new(document)

    if task_finder.last_task? and task_finder.current_task_ended?
      document.update_attribute :percentage, 100
      document.update_attribute :flagger_id, nil
    else
      klass = Kernel.const_get(
        task_finder.next_task.split('_').map(&:capitalize).join
      )
      Resque.enqueue(klass, document_id)
    end
  end
end
