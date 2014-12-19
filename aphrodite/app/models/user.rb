class User
  attr_accessor :invitation_token
  attr_accessible :username, :organization

  field :username,     type: String, default: ""
  field :organization, type: String
  field :admin,        type: Boolean
  field :access_token, :type => String

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validate :username, presence: true

  before_create :generate_access_token
  before_create :set_username

  def admin?
    !!admin
  end

private

  def generate_access_token
    self.access_token = SecureRandom.hex
  end

  def set_username
    write_attribute(:username, email.split("@")[0])
  end
end
