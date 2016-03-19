module Compote
  class Importer
    BATCH_SIZE = 10

    def initialize
      @publishers = {}
      @authors = {}
    end

    def start
      Rails.logger.tagged('importer') do
        import_books
      end
    end

    def import_books
      Source.find_in_batches(batch_size: BATCH_SIZE) do |sources|
        sources.each do |source|
          import_source source
        end
      end
    end

    def import_source(source)
      items = source.parse_body_xml
      items.each do |type, item|
        import_book_item type, item, source
      end
    end

    def import_book_item(type, item, source)
      ActiveRecord::Base.transaction do
        book = Book.find_or_create_by asin: item[:asin]
        book.released_on = item[:release_date]
        book.published_on = item[:publication_date]
        book.raw_title = item[:title]
        book.is_ebook = type == :ebook
        book.is_adult = item[:is_adult_product].to_i == 1
        book.publisher = find_publisher_by_name item[:publisher]
        book.authors = find_authors_by_names item[:authors]
        book.source = source
        book.save
      end
    rescue => e
      Rails.logger.error "import failed: { #{type}: #{item.inspect} } exception: #{e} (#{e.class})"
    end

    def find_publisher_by_name(name)
      @publishers[name] ||= Publisher.find_or_create_by name: name
    end

    def find_authors_by_names(names)
      names.map {|name| find_author_by_name name }
    end

    def find_author_by_name(name)
      @authors[name] ||= Author.find_or_create_by name: name
    end
  end
end
