module Compote
  class BookClusterer
    def initialize
      @books = []
      @clusters = Hash.new {|h,k| h[k] = [] }
    end

    def push(book)
    end

    def generate_key(publisher_name:, authors:, title:)
      author_key = self.class.generate_author_key publisher_name, authors
      series_key = self.class.generate_series_key title
      "#{author_key}/#{series_key}"
    end

    def self.generate_series_key(title)
      parsed_title = parse_title title
      series_key = parsed_title[:series]
      series_key ||= parsed_title[:title][0..2] # FIXME tekitou
      series_key
    end

    def self.generate_author_key(publisher_name, authors)
      authors = authors.gsub("\t", '-')
      "#{publisher_name}/#{authors.gsub("\t", '-')}"
    end

    def self.parse_title(title)
      result = {}

      # "恋と嘘(1) (マンガボックスコミックス)"
      #   => { label: "マンガボックスコミックス" }
      if m = title.match(/^(?<remain>.*?)\s*\((?<label>[^)]+)\)$/)
        title = m[:remain]
        result[:label] = m[:label]
      end

      # "いなり、こんこん、恋いろは。(3)<いなり、こんこん、恋いろは。>"
      #   => { series: "いなり、こんこん、恋いろは。" }
      if m = title.match(/^(?<remain>.*?)\s*<(?<series>.+)>$/)
        if m[:remain].include?(m[:series])
          title = m[:remain]
          result[:series] = m[:series]
        end
      end

      # "桜Trick 1巻 桜Trick"
      #   => { series: "桜Trick" }
      if title.match(/^(.{5}).*\1/)
        # match twice to reduce regexp costs
        if m = title.match(/^((.{5,}).*?)\s*\2$/)
          title = m[1]
          result[:series] = m[2]
        end
      end

      result.merge title: title
    end
  end
end
