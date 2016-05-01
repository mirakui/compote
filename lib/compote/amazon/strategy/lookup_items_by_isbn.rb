require 'compote/amazon/strategy'

module Compote
  module Amazon
    module Strategy
      class LookupItemsByIsbn < Base
        def params(isbn:)
          {
            'Operation' => 'ItemLookup',
            'ItemId' => isbn,
            'IdType' => 'ISBN',
            'ResponseGroup' => 'Images,ItemAttributes',
          }
        end

        def parse(body)
          result = {}

          item = item_by_type body, 'ABIS_BOOK'
          result[:book] = parse_item_node item if item

          item = item_by_type body, 'ABIS_EBOOKS'
          result[:ebook] = parse_item_node item if item

          result
        end

        private

        def item_by_type(body, type)
          body.css('Items Item').find do |x|
            x.css('ProductTypeName').text == type
          end
        end

        def parse_item_node(item)
          result = {}

          result[:authors] = item.css('Author').map(&:text)
          result[:large_image_url] = item.at_css('LargeImage URL').try(&:text)

          %w[ASIN Publisher Studio Title IsAdultProduct PublicationDate ReleaseDate].each do |name|
            key = name.underscore.intern
            value = item.at_css(name).try(&:text)
            result[key] = value if value
          end

          result
        end
      end
    end
  end
end

