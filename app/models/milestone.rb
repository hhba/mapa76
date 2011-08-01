class Milestone < Sequel::Model
  many_to_one :person
  def date_range(d)
    IncompleteDate.parse(d)
  end
  def date_from_range
    date_range(date_from)
  end
  def date_to_range
    date_range(date_to)
  end
  def self.where_list
    Milestone.select(:where).distinct(:where).map{|w| w.where}
  end
  def self.what_list
    Milestone.select(:what).distinct(:what).map{|w| w.what}
  end
end
Milestone.plugin :json_serializer
