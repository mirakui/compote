require 'compote/fetcher'
require 'compote/parser'
require 'compote/amazon_api'

module Compote
  class Crawler
    def initialize
      @fetcher = Fetcher.new
      @parser = Parser.new
      @amazon_api = AmazonApi.new
      @isbns = []
    end

    def start
      Rails.logger.tagged('crawler') do
        crawl_comic_list
        crawl_isbns
      end
    end

    def crawl_comic_list(year=nil, month=nil)
      now = Time.now
      year ||= now.year
      month ||= now.month
      ym = Time.new(year, month).strftime('%y%m')
      uri = "http://www.bookservice.jp/layout/bs/common/html/schedule/#{ym}c.html"
      page = @fetcher.fetch uri
      isbns = @parser.extract_isbns_from_comic_list_html page
      enqueue_isbns isbns
    end

    def crawl_isbns
      @isbns.each do |isbn|
        uri = @amazon_api.build_lookup_items_by_isbn isbn
        puts uri
      end
    end

    def enqueue_isbns(isbns)
      isbns.each do |isbn|
        @isbns << isbn
        # TODO
        puts "queued #{isbn}"
      end
      Rails.logger.info "enqueued #{isbns.length} ISBNs"
    end
  end
end
