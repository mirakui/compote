require 'compote/normalizer'

class Publisher < ActiveRecord::Base
  has_many :books

  before_validation :normalize_name

  protected
  def normalize_name
    self.name = Compote::Normalizer.normalize_author_name name
  end
end
