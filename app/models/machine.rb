class Machine < ApplicationRecord
  belongs_to :location

  validates :name, uniqueness: true
  validates :name, :location_id, :status, presence: true

  enum status: { inactive: 0, active: 1 }

  def to_s
    name
  end

end
