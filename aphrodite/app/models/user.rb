class User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  attr_accessor :invitation_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validate :token, unless: "invitation_token.nil?"

private

  def token
     unless Invitation.burn!(invitation_token)
       errors.add(:invitation_token)
     end
  end
end
