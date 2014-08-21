class LinkTextExtractor
  include HTTParty

  class ApiError < RuntimeError; end
  base_uri "access.alchemyapi.com/"

  def initialize(document_id)
    @document = Document.find(document_id)
    @options = {
      query: {
        apikey: ENV['ALCHEMY_API_KEY'],
        url: @document.url,
        outputMode: 'json'
      }
    }
  end

  def call
    @document.processed_text = extract_text
    page = Page.create({
      num: 1,
      text: @document.processed_text,
      form_pos: 0,
      to_pos: @document.processed_text.length
    })
    @document.pages << page
    @document.save
  end

  def extract_text
    response = get(text_path, @options)
    if response.parsed_response['status'] = 'OK'
      response.parsed_response['text']
    else
      logger.info "TEXT EXTRACTION FAILED - #{@document.document_id}"
      raise ApiError
    end
  end

  def text_path
    "/calls/url/URLGetText"
  end

  def get(url, options={})
    self.class.get(url, options)
  end
end
