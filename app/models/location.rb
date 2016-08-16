class Location < ActiveRecord::Base
  has_many :places

  validates :address, presence: true

  geocoded_by :address
  after_validation :geocode
  after_validation :geocode, :if => :address_changed? 
end