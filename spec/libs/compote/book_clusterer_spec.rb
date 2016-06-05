require 'rails_helper'
require 'compote/book_clusterer'

RSpec.describe Compote::BookClusterer, type: :model do
  describe '#parse_title' do

    {
      'いなり、こんこん、恋いろは。(3)<いなり、こんこん、恋いろは。> (角川コミックス・エース)' => {
        title: 'いなり、こんこん、恋いろは。(3)',
        series: 'いなり、こんこん、恋いろは。',
        label: '角川コミックス・エース'
      },
      '桜Trick 1巻 桜Trick (まんがタイムKRコミックス)' => {
        title: '桜Trick 1巻',
        series: '桜Trick',
        label: 'まんがタイムKRコミックス',
      },
    }.each do |title, expected|
      describe title do
        it do
          result = Compote::BookClusterer.parse_title title
          expect(result).to eq expected
        end
      end
    end
  end
end
