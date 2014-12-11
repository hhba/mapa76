class ScheduleTask < BaseTask
  @queue = :schedule_task
  @msg = "Schedule tasks"

  DEFAULT_TASKS = %w(
    text_extraction_task
    ne_finder_task
    store_task
  )

  def self.perform(input)
    self.new(input).call
  end

  def initialize(input)
    @input = input
  end

  def call
    if next_task
      klass = next_task.split('_').map(&:capitalize).join.constantize
      Resque.enqueue(klass, @input)
    end
  end

  def next_task
    if current_task == ''
      tasks.first
    else
      tasks[tasks.index(current_task) + 1]
    end
  end

  def current_task
    JSON.parse(@input).fetch('metadata', {}).fetch('current_task', '')
  end

  def tasks
    DEFAULT_TASKS
  end
end
