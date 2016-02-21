require 'compote/fetcher'

module Compote
  class Crawler
    def fetcher
      @fetcher ||= Fetcher.new
    end

    def crawl_comic_list(year=nil, month=nil)
      now = Time.now
      year ||= now.year
      month ||= now.month
      ym = Time.new(year, month).strftime('%y%m')
      uri = "http://www.bookservice.jp/layout/bs/common/html/schedule/#{ym}c.html"
      fetcher.fetch uri
    end
  end
end
