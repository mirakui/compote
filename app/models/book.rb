require 'compote/normalizer'
require 'compote/parser'

class Book < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :source

  before_validation :normalize_title

  def parse_title
    Compote::Parser.parse_series_from_book_title title
  end

  protected
  def normalize_title
    self.title = Compote::Normalizer.normalize_book_title title
  end
end
