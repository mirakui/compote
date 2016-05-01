require 'compote/amazon_api'
require 'compote/fetcher'

class Source < ActiveRecord::Base
  has_many :books

end
