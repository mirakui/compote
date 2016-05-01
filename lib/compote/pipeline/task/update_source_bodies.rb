require 'compote/pipeline/task/base'
require 'compote/fetcher'
require 'compote/parser'

module Compote
  module Pipeline
    module Task
      class UpdateSourceBodies < Base
        def initialize
          fetcher = Fetcher.new
          @strategy = Amazon::Strategy::LookupItemsByIsbn.new fetcher: fetcher
        end

        def start(month_ago=0)
          t_start = month_ago.to_i.month.ago.beginning_of_month

          Rails.logger.info "crawling ISBNs since #{t_start}"

          crawl_isbns t_start.year, t_start.month
        end

        def crawl_isbns(year=nil, month=nil)
          sources = if year && month
                      ym_since = get_ym year, month
                      Source.where('ym >= ?', ym_since)
                    else
                      Source.where('body IS NULL')
                    end
          count = sources.count
          updated_source_ids = []
          sources.each.with_index do |source, i|
            Rails.logger.info "fetching #{source.isbn} (#{i+1}/#{count})"
            body = @strategy.request isbn: source.isbn
            source.body = body
            source.crawled_at = Time.now
            source.save
            updated_source_ids << source.id
          end
          updated_source_ids
        end
      end
    end
  end
end
