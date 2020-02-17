class Location < ApplicationRecord
  #-----------------------gem milia-------------------#
  acts_as_tenant
  #-----------------------gem public_activity-------------------#
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked tenant_id: Proc.new{ Tenant.current_tenant.id }
  #-----------------------gem friendly_id-------------------#
  extend FriendlyId
  friendly_id :to_s, use: :slugged
  #-----------------------gem geocoder-------------------#
  geocoded_by :address_line
  #after_validation :geocode
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }
  #after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? || obj.city.present? and obj.city_changed? }
  #-----------------------relationships-------------------#
  has_many :members, dependent: :nullify
  has_many :skills, through: :members
  has_many :workplaces, inverse_of: :location, dependent: :restrict_with_error
  has_many :events, through: :workplaces
  has_many :jobs, through: :events
  has_many :leads, dependent: :nullify
  accepts_nested_attributes_for :workplaces, reject_if: proc { |attributes| attributes['name'].blank? }, allow_destroy: :true
  #, :reject_if => proc { |attributes| attributes['events_count'].zero? }
  #-----------------------validation-------------------#
  validates_uniqueness_of :name, scope: :tenant_id
  validates :name, presence: true
  validates :name, length: { maximum: 50 }
  validates :phone_number, length: { maximum: 144 }
  validates :email, length: { maximum: 144 }
  validates :address, length: { maximum: 255 }
  validates :slug, uniqueness: true
  validates :slug, uniqueness: { case_sensitive: false }
  #-----------------------scopes-------------------#
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :online_booking, -> { where(online_booking: true) }
  scope :has_address, ->{ where("address <> ''") }
  def self.active_or_id(record_id)
    where('id = ? OR (active=true)', record_id)    
  end
  ################TENANT VALIDATION#################
  validate :tenant_plan_quantity_limit
  def tenant_plan_quantity_limit
    if self.new_record?
      if tenant.plan == 'bronze'
        if tenant.locations.count > 0
          errors.add(:base, "Bronze plan cannot have more than 1 location. Upgrade your plan")
        end
      elsif tenant.plan == 'silver'
        if tenant.locations.count > 5
          errors.add(:base, "Silver plan cannot have more than 5 locations. Upgrade your plan")
        end
      #elsif tenant.plan == 'gold'
      end
    end
  end

  def to_s
    if name.present?
      name
    else
      id
    end
  end

  def address_line
    [country, city, zip, address].compact.join(', ')
  end
  
  def name_and_address
    name + " (" + address_line.to_s + ")"
  end
end