class ProgressBar
  attr_accessor :starting_at, :ending_at, :current, :bound

  def initialize(opt={})
    @current = opt.fetch(:starting_at, 0)
    @starting_at = opt.fetch(:starting_at, 0)
    @ending_at = opt.fetch(:ending_at, 100)
    @bound = opt.fetch(:bound, 100)
  end

  def increment
    i = 1 * (ending_at - starting_at).to_f / bound
    @current = @current + i
  end

  def progress
    @current > ending_at ? ending_at : @current
  end

  def progress=(value)
    @current = value
  end

  def starting_at=(value)
    @starting_at = value
    @current = value
  end

  def ending_at=(value)
    @ending_at = value
  end

  def bound=(value)
    @bound = value
  end

  def inspect
    "#<ProgressBar: #{current}/#{bound}>"
  end
end
