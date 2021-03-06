class Member < ApplicationRecord
  include Personable
  #-----------------------gem milia-------------------#
  acts_as_tenant
  #-----------------------gem public_activity-------------------#
  include PublicActivity::Model
  tracked owner: proc { |controller, model| controller.current_user }
  tracked tenant_id: proc { Tenant.current_tenant.id }
  #-----------------------gem friendly_id-------------------#
  extend FriendlyId
  friendly_id :full_name, use: :slugged
  #-----------------------validation-------------------#
  validates :first_name, :last_name, presence: true
  validates :first_name, :last_name, length: {maximum: 144}
  validates :slug, uniqueness: true
  validates :slug, uniqueness: {case_sensitive: false}
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true
  validates :email, :phone_number, length: {maximum: 255}

  validates :user_id, uniqueness: true, allow_blank: true # presence: true
  # validates :user_id, uniqueness: true, allow_blank: true #presence: true
  # validates_uniqueness_of :user_id, scope: :tenant_id
  # validates_uniqueness_of :email, scope: :tenant_id, allow_blank: true

  has_many :operating_hours, inverse_of: :member, dependent: :destroy
  accepts_nested_attributes_for :operating_hours, reject_if: :all_blank, allow_destroy: true
  #-----------------------relationships-------------------#
  has_one_attached :avatar
  has_many :transactions, as: :payable, dependent: :restrict_with_error
  has_many :leads, dependent: :restrict_with_error

  belongs_to :user, required: false
  belongs_to :location, optional: true, counter_cache: true
  has_many :jobs, dependent: :restrict_with_error
  has_many :events, through: :jobs
  has_many :skills, dependent: :destroy, inverse_of: :member
  has_many :comments
  has_many :service_categories, through: :skills
  #-----------------------money gem-------------------#
  monetize :balance, as: :balance_cents
  monetize :event_earnings_sum, as: :event_earnings_sum_cents
  monetize :transactions_sum, as: :transactions_sum_cents
  #-----------------------callbacks-------------------#
  after_create do
    update_attributes!(time_zone: Tenant.current_tenant.time_zone)
    if user.present?
      update_column :email, user.email # update_first_member_email
    end
  end

  after_save do
    if user.present?
      user.update_attributes!(time_zone: time_zone) # update_user_time_zone
    end
  end

  def update_events_balance
    update_column :event_earnings_sum, jobs.map(&:member_due_price).sum
    update_column :balance, (transactions_sum + event_earnings_sum)
  end

  def update_transactions_sum
    update_column :transactions_sum, transactions.map(&:amount).sum
    update_column :balance, (transactions_sum + event_earnings_sum)
  end
  #-----------------------scopes-------------------#
  # def open?  #for operating_hours
  #  operating_hours.where("? BETWEEN opens AND closes", Time.zone.now).any?
  # end
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :online_booking, -> { where(online_booking: true) }
  def self.active_or_id(record_id)
    where("id = ? OR (active=true)", record_id)
  end

  # def options_for_time_select
  #  hour = Array.new
  #  for $h in 8..21 do
  #      for $m in ['00', '15', '30', '45'] do
  #          hour.push [$h.to_s + "h" + $m.to_s, "%02d" % $h + ":" + $m + ":00"]
  #      end
  #  end
  #  hour
  # end

  def available_timeslots
    events.is_upcoming.pluck(:starts_at, :ends_at)
    # events & operating_hours
    # days: tomorrow + X days
    # select by day all timeslots
    # between member.operating_hours
    # between all event.start and event.end
    # timeslot.start
    # timeslot.duration
    # timeslot.end
    # validate overlap?

    # now = DateTime.now
    # start = DateTime.new(2018, 6, 28, 13, 00, 00)
    # stop =  DateTime.new(2018, 6, 28, 14, 00, 00)
    # p (start..stop).cover? now
    # def closed?
    #  DateTime.now.between?(DateTime.new(2018, 6, 28, 13, 00, 00), DateTime.new(2018, 6, 28, 14, 00, 00))
    # end
  end
  # def selection_fits_into_timeslot?
  #  available_timeslots.where duration =< lead.services.pluck(:duration).sum
  # end

  # ###############TENANT VALIDATION#################
  validate :tenant_plan_quantity_limit
  def tenant_plan_quantity_limit
    if new_record?
      if tenant.plan == "solo"
        if tenant.members.count > 0
          errors.add(:base, "Solo cannot have more than 1 employee. Upgrade your plan")
        end
      elsif tenant.plan == "mini"
        if tenant.members.count > 5
          errors.add(:base, "Mini plan cannot have more than 5 employees. Upgrade your plan")
        end
        # elsif tenant.plan == 'max'
      end
    end
  end
  # ###############MILIA ORG ADMIN MEMBER#################
  DEFAULT_ADMIN = {
    last_name: "Admin",
    first_name: "Admin"
  }

  def self.create_new_member(user, params)
    # add any other initialization for a new member
    user.create_member(params)
  end

  def self.create_org_admin(user)
    new_member = create_new_member(user, DEFAULT_ADMIN)
    unless new_member.errors.empty?
      raise ArgumentError, new_member.errors.full_messages.uniq.join(", ")
    end
    new_member
  end
end
