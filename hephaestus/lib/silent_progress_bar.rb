class SilentProgressBar
  attr_accessor :starting_at, :ending_at, :current, :bound, :name

  def initialize(name, bound=100, opt={})
    @name = name
    @current = opt.fetch(:starting_at, 0)
    @starting_at = opt.fetch(:starting_at, 0)
    @ending_at = opt.fetch(:ending_at, 100)
    @bound = bound
  end

  def increment
    i = 1 * (ending_at - starting_at).to_f / bound
    @current = @current + i
  end
  alias_method :inc, :increment

  def progress
    @current > ending_at ? ending_at : @current
  end

  def progress=(value)
    @current = value
  end
  alias_method :set, :'progress='

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
    "#<SilentProgressBar #{name}: #{current}/#{bound}>"
  end
end
