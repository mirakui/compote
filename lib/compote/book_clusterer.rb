module Compote
  class BookClusterer
    def initialize
      @books = []
      @clusters = Hash.new {|h,k| h[k] = [] }
    end

    def push(book)
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

      result.merge title: title
    end
  end
end
