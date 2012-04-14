class Paragraph
  include Mongoid::Document

  field :content,     :type => String
  field :information, :type => Hash

  embedded_in :document

  before_save :process_text

  def info
    output= ""
    self.information.each do |k, v|
      output << "#{k}: #{v}\n"
    end
    output
  end

  def process_text
    text = Text.new(self.content)
    self.information = {
      :addresses => text.addresses.count,
      :dates => text.dates.count,
      :people => text.person_names.count
    }
  end
end