require 'compote/normalizer'

module Compote
  class Importer
    BATCH_SIZE = 100

    def initialize
      @publishers = nil
    end

    def start(month_ago=nil)
      Rails.logger.tagged('importer') do
        sources = month_ago ? Source.where('ym >= ?', month_ago.to_i.month.ago.strftime('%y%m')) : Source.all
        import_books sources
      end
    end

    def import_books(sources)
      sources.find_in_batches(batch_size: BATCH_SIZE) do |batch_sources|
        items = batch_sources.map(&:parse_body_xml)
        asins = items.map {|v| v.values.map {|x| x[:asin] } }.flatten.compact
        cached_books = Hash[Book.where(asin: asins).to_a.map {|b| [b.asin, b] }]
        batch_sources.each_with_index do |source, i|
          items[i].each do |type, item|
            import_book_item type, item, source, cached_books
          end
        end
      end
    end

    def import_book_item(type, item, source, cached_books)
      book = cached_books[item[:asin]] || Book.new(asin: item[:asin])
      book.isbn = source.isbn
      book.released_on = item[:release_date]
      book.published_on = item[:publication_date]
      book.title = Normalizer.normalize_book_title item[:title]
      book.is_ebook = type == :ebook
      book.is_adult = item[:is_adult_product].to_i == 1
      book.publisher = find_publisher_by_name item[:publisher]
      book.authors = item[:authors].join("\t")
      book.source = source
      if book.changed?
        book.save
      end
    rescue => e
      Rails.logger.error "import failed: { #{type}: #{item.inspect} } exception: #{e} (#{e.class})"
    end

    def find_publisher_by_name(name)
      name = Normalizer.normalize_publisher_name name
      @publishers ||= Hash[Publisher.all.to_a.map {|x| [x.name, x] }]
      @publishers[name] ||= Publisher.new(name: name)
    end
  end
end
