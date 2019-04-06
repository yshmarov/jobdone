class Location < ApplicationRecord

  acts_as_tenant
  validates :name, length: { maximum: 50 }
  validates :phone_number, length: { maximum: 144 }
  validates :email, length: { maximum: 144 }
  validates :address, length: { maximum: 255 }

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked tenant_id: Proc.new{ Tenant.current_tenant.id }
  extend FriendlyId
  friendly_id :to_s, use: :slugged

  has_many :members, dependent: :restrict_with_error
  has_many :events, dependent: :restrict_with_error
  has_many :jobs, through: :events

  validates_uniqueness_of :name, scope: :tenant_id
  validates :name, :balance, :status, presence: true

  enum status: { inactive: 0, active: 1 }
  scope :active, -> { where(status: [:active]) }
  scope :inactive, -> { where(status: [:inactive]) }
  def self.active_or_id(record_id)
    where('id = ? OR (status=1)', record_id)    
  end

  monetize :balance, as: :balance_cents

  after_touch :update_balance

  def to_s
    if name.present?
      name
    else
      id
    end
  end

  validate :free_plan_can_only_have_one_location
  def free_plan_can_only_have_one_location
    if self.new_record? && (tenant.locations.count > 0) && (tenant.plan == 'bronze')
      errors.add(:base, "Free plans cannot have more than one location")
    end
  end

  #protected

  def update_balance
    update_column :balance, (jobs.map(&:client_due_price).sum)
  end

end
