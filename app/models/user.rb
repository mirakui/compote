class User < ActiveRecord::Base
  enum registration_status: { activating: 0, active: 1, leaved: 2 }
  has_secure_password
  validates_format_of :email, with: /\A\s*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*\z/i
  validates_uniqueness_of :email
  validates_length_of :email, maximum: 255
  validates_length_of :password, minimum: 6, allow_blank: true
  before_validation :strip_email

  private
  def strip_email
    self.email.strip! if self.email
  end
end
