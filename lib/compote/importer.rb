require 'compote/normalizer'

module Compote
  class Importer
    BATCH_SIZE = 100

    def initialize
      @publishers = nil
    end

    def start
      Rails.logger.tagged('importer') do
        import_books
      end
    end

    def import_books
      Source.find_in_batches(batch_size: BATCH_SIZE) do |sources|
        items = sources.map(&:parse_body_xml)
        asins = items.map {|v| v.values.map {|x| x[:asin] } }.flatten.compact
        cached_books = Hash[Book.where(asin: asins).to_a.map {|b| [b.asin, b] }]
        sources.each_with_index do |source, i|
          items[i].each do |type, item|
            import_book_item type, item, source, cached_books
          end
        end
      end
    end

    def import_book_item(type, item, source, cached_books)
      book = cached_books[item[:asin]] || Book.new(asin: item[:asin])
      book.released_on = item[:release_date]
      book.published_on = item[:publication_date]
      book.raw_title = item[:title]
      book.is_ebook = type == :ebook
      book.is_adult = item[:is_adult_product].to_i == 1
      book.publisher = find_publisher_by_name item[:publisher]
      book.authors = item[:authors].join("\t")
      book.source = source
      if book.changed?
        Book.transaction do
          book.save
        end
      end
    rescue => e
      Rails.logger.error "import failed: { #{type}: #{item.inspect} } exception: #{e} (#{e.class})"
    end

    def find_publisher_by_name(name)
      name = Compote::Normalizer.normalize_author_name name
      @publishers ||= Hash[Publisher.all.to_a.map {|x| [x.name, x] }]
      @publishers[name] ||= Publisher.new(name: name)
    end
  end
end
