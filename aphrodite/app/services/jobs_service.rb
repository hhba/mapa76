class JobsService
  def self.not_working_on?(document)
    !self.working_on?(document)
  end

  def self.working_on?(document)
    new(document).working?
  end

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def working?
    get_working_ids.include?(document.id)
  end

  def get_working_ids
    Resque.working.map do |job|
      begin
        job["payload"]["args"].first
      rescue NoMethodError
        nil
      end
    end.flatten
  end

end
