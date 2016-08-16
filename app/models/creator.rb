class Creator < ActiveRecord::Base
  has_many :places, :dependent => :destroy 

  # Lowercase email before saving to db
  before_save { self.email = email.downcase }

  validates :displayname, presence: true
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :email, uniqueness: { case_sensitive: false }, on: :create

  # Using the bcrypt gem, has some built in validation
  has_secure_password
end
