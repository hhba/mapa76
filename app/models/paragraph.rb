class Paragraph
  include Mongoid::Document
  include Mongoid::Pagination

  field :content,     :type => String
  field :information, :type => Hash
  field :pos,         :type => Integer

  belongs_to :document

  def info
    output= ""
    # self.information.each do |k, v|
    #   output << "#{k}: #{v}\n"
    # end
    output
  end

  def first_words
    self.content[0..40]
  end

  def named_entities
    self.document.named_entities.where(
      :pos.gt => self.pos,
      :pos.lt => self.pos + self.content.size,
    ).map do |ne|
      {:text => ne.text, :tag => ne.tag}
    end
  end
end
