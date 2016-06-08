require 'rails_helper'
require 'compote/book_clusterer'
require 'csv'

RSpec.describe Compote::BookClusterer, type: :model do
  describe '#parse_title' do

    CSV.foreach(Rails.root.join('spec/data/book_clusters.csv').to_s, headers: true) do |row|
      describe row['original_title'] do
        it do
          result = Compote::BookClusterer.parse_title row['original_title']
          expect(result).to eq(
            title: row['title'],
            series: row['series'],
            #series_key: row['series_key'],
          )
        end
      end
    end
  end
end
