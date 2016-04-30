require 'compote/fetcher'
require 'compote/parser'
require 'compote/amazon_api'

module Compote
  class Crawler
    def initialize
      @fetcher = Fetcher.new
      @amazon_api = AmazonApi.new
      @isbns = []
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

      Rails.logger.info "crawling ISBNs since #{t_start}"

      crawl_isbns t_start.year, t_start.month
    end

    def crawl_comic_list(year=nil, month=nil)
      ym = get_ym year, month
      uri = "http://www.bookservice.jp/layout/bs/common/html/schedule/#{ym}c.html"
      Rails.logger.info "fetching #{uri}"
      page = @fetcher.fetch uri
      isbns = Parser.extract_isbns_from_comic_list_html page
      Rails.logger.info "#{isbns.length} ISBNs"
      create_sources_by_isbns isbns, ym
      return isbns.length
    end

    def crawl_isbns(year=nil, month=nil)
      sources = if year && month
                  ym_since = get_ym year, month
                  Source.where('ym >= ?', ym_since)
                else
                  Source.where('body IS NULL')
                end
      count = sources.count
      sources.each.with_index do |source, i|
        Rails.logger.info "fetching #{source.isbn} (#{i+1}/#{count})"
        uri = @amazon_api.build_lookup_items_by_isbn source.isbn
        source.body = @fetcher.fetch uri
        source.save
      end
    end

    def get_ym(year=nil, month=nil)
      t = Time.now
      Time.new(year || t.year, month || t.month).strftime('%y%m')
    end

    def create_sources_by_isbns(isbns, ym)
      sources = isbns.map {|isbn| Source.new isbn: isbn, ym: ym }
      Source.import sources, on_duplicate_key_update: { ym: 'ym' }
    end
  end
end
