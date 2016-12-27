class User < ApplicationRecord
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, 
     :omniauth_providers => [:facebook, :twitter, :google_oauth2, :linkedin]

  has_many :identities, dependent: :destroy


  def self.find_for_oauth(auth, signed_in_resource = nil)
    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)
    user = signed_in_resource ? signed_in_resource : identity.user
    # Create the user if needed
    if user.nil?
      email_is_verified = auth.info.email
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email
      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          #username: auth.info.nickname || auth.uid,
          email: email ? email : "#{auth.uid}@#{auth.provider}.com",
          password: Devise.friendly_token[0,20]
        )
        user.skip_confirmation! if user.respond_to?(:skip_confirmation)
        user.save!
      end
    end
    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  # def email_verified?
  #   self.email && self.email !~ TEMP_EMAIL_REGEX
  # end
end
