class MentionsFinderTask < Base
  attr_accessor :document, :user, :named_entities
  @queue = :mentions_finder_task

  def self.perform(document_id)
    self.new(document_id).call
  end

  def initialize(document_id)
    @document = Document.find(document_id)
    @user = @document.user
    @named_entities = @document.named_entities.where(ne_class: 'organizations')
  end

  def call
    dupplicates.each do |org|
      organization = user.organizations.where(name: org[:name]).first
      if organization
        organization.mentions = organization.mentions.merge({document.id.to_s => org[:size]})
        organization.save
      else
        organization = Organization.create name: org[:name],
                                           mentions: { document.id.to_s => org[:size] }
        user.organizations << organization
      end
      document.organizations << organization
    end
  end

  def dupplicates
    org_names = named_entities.map(&:text)
    org_names.uniq.map do |org_name|
      {
        name: org_name,
        size: named_entities.select { |ne| ne.text == org_name }.size
      }
    end
  end

  def documents
    @documents ||= user.documents
  end
end
