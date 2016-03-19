require 'compote/normalizer'

module Compote
  class Parser
    def self.extract_isbns_from_comic_list_html(page)
      page.scan(/>\s*(9784\d+)\s*</).map {|m| m[0] }
    end

    TITLE_PATTERNS = [
      /\A(?<title>.*?)\s*\((?<num>\d+)\)/,
      /\A(?<title>.*?)\s*(?<num>\d+)巻?/,
      /\A(?<title>.*?)\s*[:\(]/,
    ]
    def self.parse_series_from_book_title(title)
      title = Normalizer.normalize_book_title title
      TITLE_PATTERNS.each do |ptn|
        if m=ptn.match(title)
          res = {}
          m.names.each {|k| res[k.to_sym] = m[k] }
          return res
        end
      end
      { title: title }
    end
  end
end
