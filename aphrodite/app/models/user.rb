class User
  attr_accessor :invitation_token

  field :name,         type: String
  field :organization, type: String
  field :admin,        type: Boolean
  field :access_token,        :type => String

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validate :has_invitation_token, unless: "invitation_token.nil?"
  validate :name, presence: true

  before_create :generate_access_token

  def admin?
    !!admin
  end

private

  def has_invitation_token
     unless Invitation.burn!(invitation_token)
       errors.add(:invitation_token)
     end
  end

  def generate_access_token
    self.access_token = SecureRandom.hex
  end
end
