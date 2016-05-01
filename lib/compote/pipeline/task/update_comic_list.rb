require 'compote/pipeline/task/base'

module Compote
  module Pipeline
    module Task
      class UpdateComicList < Base
        def initialize
          @fetcher = Fetcher.new
        end

        def start(month_ago=0)
          t_start = month_ago.to_i.month.ago.beginning_of_month

          Rails.logger.info "crawling comic list since #{t_start}"

          t = t_start
          isbns_len = nil
          loop do
            isbns_len = crawl_comic_list t.year, t.month
            t = 1.month.since t
            break if isbns_len == 0
          end
        end

        def crawl_comic_list(year=nil, month=nil)
          ym = get_ym year, month
          uri = "http://www.bookservice.jp/layout/bs/common/html/schedule/#{ym}c.html"
          Rails.logger.info "fetching #{uri}"
          page = @fetcher.fetch uri
          isbns = extract_isbns_from_comic_list_html page
          Rails.logger.info "#{isbns.length} ISBNs"
          create_sources_by_isbns isbns, ym
          return isbns.length
        end

        def create_sources_by_isbns(isbns, ym)
          sources = isbns.map {|isbn| Source.new isbn: isbn, ym: ym }
          Source.import sources, on_duplicate_key_update: { ym: 'ym' }
        end

        private
        def extract_isbns_from_comic_list_html(page)
          page.scan(/>\s*(9784\d+)\s*</).map {|m| m[0] }
        end
      end
    end
  end
end
