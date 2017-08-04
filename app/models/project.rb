class Project < ApplicationRecord
  has_many :videos, dependent: :destroy
  validates_presence_of :hashed_id
end
