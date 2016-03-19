module Compote
  class Normalizer
    def self.normalize_publisher_name(name)
      name.unicode_normalize(:nfkc).gsub(/\s+/, '')
    end

    def self.normalize_book_title(title)
      title.unicode_normalize(:nfkc).gsub(/\s+/, ' ')
    end
  end
end
