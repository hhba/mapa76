require 'open-uri'
require 'httparty'
require 'nokogiri'

class LinksProcessorTask < Base
  @queue = :links_processor_task
  @msg = "Procesando enlaces"

  include HTTParty

  class ApiError < RuntimeError; end
  base_uri "access.alchemyapi.com/"

  def self.perform(document_id)
    self.new(document_id).call
  end

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
    @document.title = extract_title
    @document.processed_text = extract_text
    extract_entities.each do |entity|
      store(entity)
    end
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
      logging("CAN NOT STORE #{entity.inspect}")
    end
  end

  def store_person(entity)
    person = @user.people.where(name: entity['text']).first
    if person
      person.mentions.merge({@document.id.to_s => entity['count'].to_i})
      person.save
    else
      person = Person.create name: entity['text'],
                              mentions: { @document.id.to_s => entity['count']},
                              lemma: entity['text'].parameterize
      @user.people << person
    end
    @document.people << person
  end

  def store_organization(entity)
    organization = @user.organizations.where(name: entity['text']).first
    if organization
      organization.mentions.merge({@document.id.to_s => entity['count']})
      organization.save
    else
      organization = Organization.create(name: entity['text'],
        lemma: entity['text'].parameterize,
        mentions: { @document.id.to_s => entity['count']}
      )
      @user.organizations << organization
    end
    @document.organizations << organization
  end

  def store_place(entity)
    place = @user.places.where(name: entity['text']).first
    if place
      place.mentions.merge({@document.id.to_s => entity['count']})
      place.save
    else
      place = Place.create(name: entity['text'],
        lemma: entity['text'].parameterize,
        mentions: { @document.id.to_s => entity['count']}
      )
      @user.places << place
    end
    @document.places << place
  end

  def extract_title
    doc = Nokogiri::HTML(open(@document.url))
    doc.css('title').text
  end

  def extract_text
    response = get(text_path, @options)
    if response.parsed_response['status'] = 'OK'
      response.parsed_response['text']
    else
      logging 'TEXT EXTRACTION FAILED'
      raise ApiError
    end
  end

  def extract_entities
    response = get(entities_path, @options)
    if response.parsed_response['status'] == 'OK'
      response.parsed_response['entities']
    else
      logger 'ENTITIES EXTRACTION FAILED'
      raise ApiError
    end
  end

  def entities_path
    "/calls/url/URLGetRankedNamedEntities"
  end

  def text_path
    "/calls/url/URLGetText"
  end

  def logging(msg)
    self.class.logging(msg)
  end

  def get(url, options={})
    self.class.get(url, options)
  end
end
