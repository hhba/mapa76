require 'active_support/all'

class DocumentProcessBootstrapTask
  attr_reader :document, :task_finder
  @queue = :document_process_bootstrap_task

  def self.perform(document_id)
    self.new(document_id).call
  end

  def initialize(document_id)
    @document = Document.find(document_id)
    @task_finder = TaskFinder.new(document)
  end

  def call
    if document.link_document?
      link_document
    else
      file_document
    end
  end

  def link_document
    if document.status =~ /end/
      document.update_attribute :status_msg, 'Completado'
      document.update_attribute :percentage, 100
    else
      Resque.enqueue(LinksProcessorTask, document_id)
    end
  end

  def file_document
    if task_finder.last_task? and task_finder.current_task_ended?
      document.update_attribute :status_msg, 'Completado'
      document.update_attribute :percentage, 100
      document.update_attribute :flagger_id, nil
    else
      klass = task_finder.next_task.split('_').map(&:capitalize).join.constantize
      Resque.enqueue(klass, document_id)
    end
  end

private

  def document_id
    document.id.to_s
  end
end
