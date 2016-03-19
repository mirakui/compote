module Compote
  class Exporter
    def initialize(path)
      @path = Pathname.new path
    end

    def start
      @path.open('w') do |f|
        Book.order(:title).each do |book|
          parsed = book.parse_title
          f.puts [
            book.isbn,
            book.asin,
            book.title,
            parsed[:title],
            parsed[:num],
          ].join("\t")
        end
      end
    end
  end
end
