module Compote
  class Normalizer
    def self.normalize_publisher_name(name)
      name.unicode_normalize(:nfkc).gsub(/\s+/, '')
    end

    def self.normalize_book_title(title)
      title.unicode_normalize(:nfkc).gsub(/\s+/, ' ')
    end

    def self.normalize_date(date)
      if date && date =~ /\A\d{4}-\d{2}\z/
        "#{date}-01"
      else
        date
      end
    end
  end
end
