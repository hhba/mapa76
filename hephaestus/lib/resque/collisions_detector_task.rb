class CollisionsDetectorTask < Base
  @queue = :collisions_detector_task

  attr_reader :document

  def perform(id)
    self.new(id).call
  end

  def initialize(id)
    @document = Document.find(id)
  end

  def call
    addresses = document.named_entities.where(ne_class: :addresses)
    other_entities = document.named_entities.ne(ne_class: :addresses)
    other_entities.each do |ne|
      addresses.each do |ae|
        collision = (ne.inner_pos['from_pos']...ne.inner_pos['to_pos']).to_a &
        (ae.inner_pos['from_pos']...ae.inner_pos['to_pos']).to_a
        unless collision.empty?
          logger.debug "[COLLISION] #{ne.text}"
          ne.update_attribute :collisioned, true
        end
      end
    end
  end
end