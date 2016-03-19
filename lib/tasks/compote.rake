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
