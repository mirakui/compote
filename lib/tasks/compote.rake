require 'compote/crawler'
require 'compote/importer'
require 'compote/exporter'
require 'dotenv/tasks'

namespace :compote do
  namespace :crawler do
    desc 'start crawler'
    task start: :environment do
      crawler = Compote::Crawler.new
      crawler.start
    end

    task start_old_comic_list: :environment do
      crawler = Compote::Crawler.new
      t = Time.new 2012, 2
      t_end = Time.new 2016, 4, 30
      while t <= t_end
        crawler.crawl_comic_list t.year, t.month
        t = 1.month.since t
      end
    end
  end

  namespace :books do
    desc 'import books from crawled items'
    task import: :environment do
      importer = Compote::Importer.new
      importer.start
    end

    desc 'export book titles as TSV'
    task export: :environment do
      raise 'please specify output filename as ENV["FILE"]' unless ENV['FILE']
      exporter = Compote::Exporter.new ENV['FILE']
      exporter.start
    end
  end
end
