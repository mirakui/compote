require 'compote/fetcher'
require 'compote/parser'

module Compote
  class Crawler
    def fetcher
      @fetcher ||= Fetcher.new
    end

    def parser
      @parser ||= Parser.new
    end

    def start
      Rails.logger.tagged('crawler') do
        crawl_comic_list
      end
    end

    def crawl_comic_list(year=nil, month=nil)
      now = Time.now
      year ||= now.year
      month ||= now.month
      ym = Time.new(year, month).strftime('%y%m')
      uri = "http://www.bookservice.jp/layout/bs/common/html/schedule/#{ym}c.html"
      page = fetcher.fetch uri
      isbns = parser.extract_isbns_from_comic_list_html page
      enqueue_isbns isbns
    end

    def enqueue_isbns(isbns)
      isbns.each do |isbn|
        # TODO
        puts "queued #{isbn}"
      end
      Rails.logger.info "enqueued #{isbns.length} ISBNs"
    end
  end
end
