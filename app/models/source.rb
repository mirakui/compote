require 'compote/amazon_api'
require 'compote/fetcher'

class Source < ActiveRecord::Base
  has_many :books

  include AmazonParser

  def fetch
    api = Compote::AmazonApi.new
    fetcher = Compote::Fetcher.new
    uri = api.build_lookup_items_by_isbn self.isbn
    self.body = fetcher.fetch uri
    self.crawled_at = Time.now
    self
  end
end
