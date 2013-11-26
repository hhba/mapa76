class TaskFinder
  attr_reader :document

  DEFAULT_TASKS = %w(
    text_extraction_task
    extraction_task
    coreference_resolution_task
  )

  def initialize(document)
    @document = document
  end

  def next_task
    if current_task_ended?
      tasks[tasks.index(current_task) + 1]
    else
      current_task
    end
  end

  def last_task?
    current_task == tasks.last
  end

  def current_task
    if document.status == ''
      tasks.first
    else
      document.status.split('-')[0]
    end
  end

  def index
    tasks.index(current_task)
  end

  def count
    tasks.length
  end

  def current_task_ended?
    if document.status == ''
      false
    else
      document.status.split('-')[1] == 'end'
    end
  end

  def tasks
    if document.tasks.empty?
      DEFAULT_TASKS
    else
      document.tasks
    end
  end
end
