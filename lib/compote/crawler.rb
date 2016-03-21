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

    #def start
    #  Rails.logger.tagged('crawler') do
    #    crawl_comic_list
    #    #crawl_isbns
    #  end
    #end

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
      #enqueue_isbns isbns
      create_sources_by_isbns isbns, ym
    end

    def crawl_isbns
      sources = Source.where('body IS NULL')
      count = sources.count
      sources.each.with_index do |source, i|
        Rails.logger.info "fetching #{source.isbn} (#{i+1}/#{count})"
        uri = @amazon_api.build_lookup_items_by_isbn isbn
        source.body = @fetcher.fetch uri
        source.save
      end
    end

    def create_sources_by_isbns(isbns, ym)
      sources = isbns.map {|isbn| Source.new isbn: isbn, ym: ym }
      Source.import sources, on_duplicate_key_update: { ym: 'ym' }
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
