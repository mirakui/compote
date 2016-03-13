class CrawledResponse < ActiveRecord::Base
  include AmazonParser

  LIFETIME_SEC = 1.day

  def expired?
    return false if Rails.env.development?
    Time.now - self.updated_at > LIFETIME_SEC
  end
end
