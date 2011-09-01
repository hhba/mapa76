require "date"
class IncompleteDate
  include Comparable
  def initialize(year,month=nil,day=nil)
    if year.is_a?(Date)
      day = year.day
      month = year.month
      year = year.year
    end
    #convert falses in nils
    @parts = [year || nil,month || nil,day || nil]
    raise ArgumentError if ! year
    from = Date.new(year, month || 1, day || 1)
    to   = Date.new(year, month || -1, day || -1)
    @range = (from .. to)
  end
  def self.parse(str)
    "Parses a string like '1999-00' into IncompleteDate.new(1999)"
    return nil if str.nil?
    p = str.split(/[-\/]/).map{|n| n.to_i > 0 && n.to_i }
    return nil if p.length == 0
    new(*p)
  end
  def <=>(o)
    comparable_begin = o.respond_to?(:begin) ? o.begin : o
    comparable_last = o.respond_to?(:last) ? o.last : o
    if @range.begin < comparable_begin 
      -1
    elsif @range.end > comparable_last
      1
    elsif  @range.begin == comparable_begin and @range.end == comparable_last
      0
    else
      raise "I don't know how #{o} compares to #{self}"
    end
  end
  def to_s(fill=nil)
    #fill the unknown parts with #{fill}
    @parts.map{|n| n || fill}.compact.join("-")    
  end
  def begin
    @range.begin
  end
  def last
    @range.last
  end
  def partial?
    "returns true if date is partial"
    @range.begin != @range.last
  end
end
