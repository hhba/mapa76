class ProgressHandler
  attr_accessor :document, :bound

  def initialize(document, opt={})
    @document = document
    @bound = opt.fetch(:bound, 100)
  end

  def increment
    progress_bar.increment
    update(progress_bar.progress)
  end

  def increment_to(value)
    progress_bar.progress = value
    update(progress_bar.progress)
  end

  def progress_bar
    @progress_bar ||= ProgressBar.new starting_at: starting_at,
      ending_at: ending_at, bound: bound
  end

  def starting_at
    task_finder.index * step
  end

  def ending_at
    (task_finder.index + 1) * step
  end

  def step
    100.0 / task_finder.count
  end

  def task_finder
    @task_finder ||= TaskFinder.new(document)
  end

  def update(value)
    document.update_attribute :percentage, value
  end
end
