require 'compote/crawler'
require 'compote/importer'
require 'compote/exporter'
require 'compote/pipeline/daily_update'
require 'dotenv/tasks'

namespace :compote do
  namespace :crawler do
    desc 'start crawler'
    task :start, [:month_ago] => :environment do |task, args|
      crawler = Compote::Crawler.new
      crawler.start args[:month_ago]
    end

    task isbns: :environment do
      crawler = Compote::Crawler.new
      crawler.crawl_isbns
    end

    task test: :environment do
      pipe = Compote::Pipeline::DailyUpdate.new
      pipe.start month_ago: 0
    end
  end

  namespace :books do
    desc 'import books from crawled items'
    task :import, [:month_ago] => :environment do |task, args|
      importer = Compote::Importer.new
      importer.start args[:month_ago]
    end

    desc 'export book titles as TSV'
    task export: :environment do
      raise 'please specify output filename as ENV["FILE"]' unless ENV['FILE']
      exporter = Compote::Exporter.new ENV['FILE']
      exporter.start
    end
  end
end
