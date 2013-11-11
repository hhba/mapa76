class User
  attr_accessor :invitation_token

  field :name, type: String
  field :organization, type: String

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validate :token, unless: "invitation_token.nil?"
  validate :name, presence: true

private

  def token
     unless Invitation.burn!(invitation_token)
       errors.add(:invitation_token)
     end
  end
end
