require 'compote/fetcher'
require 'compote/amazon/strategy/lookup_items_by_isbn'

module Compote
  module Amazon
    class Client
      def initialize
        @fetcher = Fetcher.new
      end

      def lookup_items_by_isbn(isbn)
        strategy = Strategy::LookupItemsByIsbn.new fetcher: @fetcher
        binding.pry
        strategy.execute isbn: isbn
      end
    end
  end
end
