class DocumentFailure
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :message,   type: String
  field :backtrace, type: String

  belongs_to :document
end
