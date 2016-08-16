class Place < ActiveRecord::Base
  belongs_to :creator
  belongs_to :location

  validates :placetype, presence: true, :length   => { :maximum => 30 }
  validates :placename, presence: true, :length   => { :maximum => 30 }
  validates :description, presence: true, :length   => { :maximum => 300 }
  
  # Only allowing grades 1 - 5
  validates :grade, numericality: { :greater_than => 0, :less_than_or_equal_to => 5 }, presence: true
  
  validates :location_id, presence: true
  validates :creator_id, presence: true
end

