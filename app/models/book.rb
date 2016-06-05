require 'compote/normalizer'

class Book < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :source

  before_validation :normalize_title

  protected
  def normalize_title
    self.title = Compote::Normalizer.normalize_book_title title
  end
end
