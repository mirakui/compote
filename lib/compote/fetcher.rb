require 'open-uri'
require 'digest/sha2'

module Compote
  class Fetcher
    def fetch(uri)
      page = nil
      Rails.logger.tagged('fetcher') do
        unless Rails.env.production?
          cache = read_cache uri
          return cache if cache
        end
        Rails.logger.info "fetching #{uri.to_s}"
        page = open(uri.to_s).read
        local_path(uri).open('wb') do |f|
          f.write page
        end
      end
      page
    end

    def local_path(uri)
      digest = Digest::SHA2.hexdigest uri.to_s
      dir = cache_dir.join digest[0..2], digest[2..4]
      FileUtils.mkdir_p dir.to_s unless dir.exist?
      dir.join digest
    end

    def cache_dir
      @cache_dir ||= begin
                       dir = Rails.root.join 'tmp', 'fetcher'
                       FileUtils.mkdir dir.to_s unless dir.exist?
                       dir
                     end
    end

    def read_cache(uri)
      cache = local_path uri
      if cache.exist?
        cache.read
      else
        nil
      end
    end
  end
end
