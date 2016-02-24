class CrawledResponse < ActiveRecord::Base
  LIFETIME_SEC = 1.day

  def expired?
    Time.now - self.updated_at > LIFETIME_SEC
  end
end
