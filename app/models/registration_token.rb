class RegistrationToken
  EXPIRES_IN = 1.day
  class NotFound < StandardError; end
  class InvalidToken < StandardError; end

  include ActiveModel::Model

  attr_accessor :value, :user_id
  validates_format_of :value, with: /\A[a-z0-9]{64}\z/
  validates_presence_of :user_id

  def self.create(user_id:)
    value = Digest::SHA2.hexdigest rand.to_s
    new value: value, user_id: user_id
  end

  def cache_key
    self.class.cache_key value
  end

  def self.cache_key(value)
    "registration_token/#{value}"
  end

  def save!
    validate!
    Rails.cache.write cache_key, user_id, expires_in: EXPIRES_IN
  end

  def validate!
    raise InvalidToken, "token #{value.inspect} is invalid" unless valid?
  end

  def delete
    Rails.cache.delete cache_key
  end

  def self.find(value)
    user_id = Rails.cache.read cache_key(value)
    token = new value: value, user_id: user_id
    if token
      token.validate!
      token
    else
      raise NotFound, "token #{value.inspect} not found"
    end
  end
end
