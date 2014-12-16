require 'json'


class SchedulerTask
  @queue = "scheduler_task"
  @msg = "Scheduling"

  DEFAULT_TASKS = %w(
    extraction_text_task
    store_text_task
    named_entities_recognition_task
    store_named_entities_task
    coreference_resolution_task
    mentions_finder_task
    indexer_task
  )

  def self.perform(input)
    self.new(JSON.parse(input)).call
  end

  attr_reader :input

  def initialize(input)
    @input = input
    @metadata = input['metadata']
    @current_task = input['metadata']['current_task']
  end

  def call
    Resque.enqueue(next_task_class, input.to_json) if next_task?
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
    DEFAULT_TASKS
  end
end
