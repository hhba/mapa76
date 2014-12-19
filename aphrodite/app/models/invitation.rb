class Invitation
  include Mongoid::Document

  field :name,         type: String
  field :organization, type: String
  field :email,        type: String
  field :reason,       type: String
  field :token,        type: String, default: ''
  field :burned_at,    type: DateTime

  validates :name, :email, presence: true
  validates :email, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  before_create :generate_token

private

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
