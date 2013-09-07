class TaskFinder
  attr_reader :document

  DEFAULT_TASKS = %w(
    normalization_task
    layout_analysis_task
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
    if document.status
      document.status.split('-')[0]
    else
      tasks.first
    end
  end

  def current_task_ended?
    if document.status
      document.status.split('-')[1] == 'end'
    else
      false
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
