module Compote
  class Normalizer
    def self.normalize_author_name(name)
      name.unicode_normalize(:nfkc).gsub(/\s+/, '')
    end
  end
end
