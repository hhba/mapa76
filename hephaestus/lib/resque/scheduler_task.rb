require 'json'


class SchedulerTask
  @queue = "scheduler"
  @msg = "Scheduling"

  FILE_DOCUMENT_TASKS = %w(
    extraction_text_task
    store_text_task
    named_entities_recognition_task
    store_named_entities_task
    coreference_resolution_task
    mentions_finder_task
    indexer_task
  )

  LINK_DOCUMENT_TASKS = %W(
    links_processor_task
  )

  def self.perform(input)
    self.new(JSON.parse(input)).call
  end

  attr_reader :input

  def initialize(input)
    @input = input
    @metadata = input['metadata']
    @document_type = input['metadata']['document_type']
    @current_task = input['metadata']['current_task']
  end

  def call
    if next_task?
      update_document_status
      Resque.enqueue(next_task_class, input.to_json)
    else
      close_document
    end
  end

  def next_task?
    if @current_task.nil?
      true
    elsif @metadata['next_task'].nil?
      !!default_next_task
    else
      !!@metadata['next_task']
    end
  end

  def next_task_class
    next_task.split('_').map(&:capitalize).join.constantize
  end

  def next_task_msg
    if next_task_class.instance_variable_defined?(:@msg)
      next_task_class.instance_variable_get(:@msg)
    else
      "Procesando"
    end
  end

  def next_task
    if @current_task.nil?
      tasks.first
    elsif @metadata['next_task']
      @metadata['next_task']
    else
      default_next_task
    end
  end

  def default_next_task
    tasks[tasks.index(@current_task) + 1]
  end

  def tasks
    if @document_type == 'link_document'
      LINK_DOCUMENT_TASKS
    else
      FILE_DOCUMENT_TASKS
    end
  end

  def update_document_status
    document.update_attribute :status_msg, next_task_msg
  end

  def close_document
    document.update_attribute :status_msg, 'Completado'
    document.update_attribute :percentage, 100
    document.update_attribute :flagger_id, nil
  end

  def document
    @document ||= Document.find(input['metadata']['document_id'])
  end
end
