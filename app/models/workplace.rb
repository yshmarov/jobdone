class Workplace < ApplicationRecord
  #-----------------------gem milia-------------------#
  acts_as_tenant
  #-----------------------relationships-------------------#
  belongs_to :location
  has_many :events, dependent: :restrict_with_error
  has_many :jobs, through: :events
  #-----------------------validation-------------------#
  validates :name, presence: true
  validates :name, length: {maximum: 20}
  validates_uniqueness_of :name, scope: :location_id
  def to_s
    # name
    # name + "/" + location.name
    location.name + "/" + name
  end

  def short_name
    to_s
  end
  #-----------------------gem friendly_id-------------------#
  extend FriendlyId
  friendly_id :generated_slug, use: :slugged
  def generated_slug
    require "securerandom"
    @random_slug ||= persisted? ? friendly_id : SecureRandom.hex(4)
  end
end
