require 'httparty'


class LinkEntitiesExtractor
  include HTTParty

  class ApiError < RuntimeError; end
  base_uri "access.alchemyapi.com/"

  def initialize(document_id)
    @document = Document.find(document_id)
    @user = @document.user
    @options = {
      query: {
        apikey: ENV['ALCHEMY_API_KEY'],
        url: @document.url,
        outputMode: 'json'
      }
    }
  end

  def call
    extract_entities.each do |entity|
      store(entity)
    end
    @document.context(force: true)
    @document.save
  end

  def store(entity)
    places = %W(City Continent Country Facility GeographicFeature Region StateOrCounty)
    people = %W(Person)
    organizations = %W(Organization Company)

    if people.include?(entity['type'])
      store_person(entity)
    elsif places.include?(entity['type'])
      store_place(entity)
    elsif organizations.include?(entity['type'])
      store_organization(entity)
    else
      logger.info("CAN NOT STORE #{entity.inspect}")
    end
  end

  def store_person(entity)
    person = @user.people.where(name: entity['text']).first
    if person
      person.mentions = person.mentions.merge({@document.id.to_s => entity['count'].to_i})
      person.save
    else
      person = Person.create name: entity['text'],
                              mentions: { @document.id.to_s => entity['count'].to_i},
                              lemma: entity['text'].parameterize
      @user.people << person
    end
    @document.people << person
  end

  def store_organization(entity)
    organization = @user.organizations.where(name: entity['text']).first
    if organization
      organization.mentions = organization.mentions.merge({@document.id.to_s => entity['count'].to_i})
      organization.save
    else
      organization = Organization.create(name: entity['text'],
        lemma: entity['text'].parameterize,
        mentions: { @document.id.to_s => entity['count'].to_i}
      )
      @user.organizations << organization
    end
    @document.organizations << organization
  end

  def store_place(entity)
    place = @user.places.where(name: entity['text']).first
    if place
      place.mentions = place.mentions.merge({@document.id.to_s => entity['count'].to_i})
      place.save
    else
      place = Place.create(name: entity['text'],
        lemma: entity['text'].parameterize,
        mentions: { @document.id.to_s => entity['count'].to_i}
      )
      @user.places << place
    end
    @document.places << place
  end

  def extract_entities
    response = get(entities_path, @options)
    if response.parsed_response['status'] == 'OK'
      response.parsed_response['entities']
    else
      logger.info 'ENTITIES EXTRACTION FAILED'
      raise ApiError
    end
  end

  def entities_path
    "/calls/url/URLGetRankedNamedEntities"
  end

  def get(url, options={})
    self.class.get(url, options)
  end
end
