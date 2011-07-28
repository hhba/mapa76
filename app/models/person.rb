class Person < Sequel::Model
  one_to_many :milestones
  def timeline(from=nil,to=nil)
    milestones = self.milestones
    t={}
    t[:id] = "person_#{id}"
    t[:title] = "#{name} - #{from} - #{to}"
    t[:initial_zoom] = "36"
    t[:color] = "#dd0000"
    t[:focus_date] = milestones.first.date_from_range.to_s(1)
    t[:events] = milestones.map{|m|
      r={}
      r[:id] = "person_#{id}_m_#{m.id}"
      r[:title] = m.what
      r[:description] = "#{m.what} - #{m.where}"
      r[:startdate] = m.date_from_range.to_s(1)
      r[:enddate] = (m.date_to_range.to_s(1) if m.date_to_range)
      r[:date_display] = m.date_from_range.partial? ? :month : :day
      r[:importance] = 20
      r[:icon] = "square_blue.png"
      r
    }
    t
  end
end
