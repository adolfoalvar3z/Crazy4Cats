class Post < ApplicationRecord
  belongs_to :user
  has_many :comments

  include PgSearch::Model
  pg_search_scope :search_full_text, against: {
    title: 'A',
    message: 'B'
  }
end
