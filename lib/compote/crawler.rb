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
      t_start = month_ago.to_i.month.ago

      Rails.logger.info "crawling comic list since #{t_start}"

      t = t_start
      isbns_len = nil
      loop do
        isbns_len = crawl_comic_list t.year, t.month
        t = 1.month.since t
        break if isbns_len == 0
      end

      Rails.logger.info "crawling ISBNs since #{t_start}"

      crawl_isbns t_start
    end

    def crawl_comic_list(year=nil, month=nil)
      now = Time.now
      year ||= now.year
      month ||= now.month
      ym = Time.new(year, month).strftime('%y%m')
      uri = "http://www.bookservice.jp/layout/bs/common/html/schedule/#{ym}c.html"
      Rails.logger.info "fetching #{uri}"
      page = @fetcher.fetch uri
      isbns = Parser.extract_isbns_from_comic_list_html page
      Rails.logger.info "#{isbns.length} ISBNs"
      create_sources_by_isbns isbns, ym
      return isbns.length
    end

    def crawl_isbns(since=nil)
      sources = if since
                  Source.where('created_at >= ?', since)
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

    def create_sources_by_isbns(isbns, ym)
      sources = isbns.map {|isbn| Source.new isbn: isbn, ym: ym }
      Source.import sources, on_duplicate_key_update: { ym: 'ym' }
    end
  end
end
