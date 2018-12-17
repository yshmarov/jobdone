class Job < ApplicationRecord

  acts_as_tenant

  #after_save :update_associated_columns
  #after_update :update_associated_columns
  after_create :update_associated_columns
  after_update :update_ends_at
  after_create :update_due_prices
  after_update :update_due_prices
  after_save :update_due_prices
  after_save :touch_associations
  after_create :touch_associations
  before_validation do
    self.ends_at = starts_at + service_duration*60
  end

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  extend FriendlyId
  friendly_id :full_name, use: :slugged

  #counter_cache for job_count
  #touch to calculate balance
  belongs_to :client, touch: true, counter_cache: true
  belongs_to :service, counter_cache: true
  belongs_to :location, touch: true, counter_cache: true
  belongs_to :member, touch: true, counter_cache: true
  belongs_to :creator, class_name: 'Member', foreign_key: :created_by, required: false
  #has_many :comments, as: :commentable

  enum status: { planned: 0, confirmed: 1, confirmed_by_client: 2,
                  not_attended: 3, rejected_by_us:4, cancelled_by_client: 5}

  scope :mark_attendance, -> { where("starts_at < ?", Time.zone.now+15.minutes).where(status: 'planned') }
  scope :upcoming, -> { where("starts_at > ?", Time.zone.now-15.minutes).where(status: 'planned') }
  scope :is_confirmed, -> { where(status: [:confirmed, :confirmed_by_client]) }
  scope :is_cancelled, -> { where(status: [:not_attended, :rejected_by_us, :cancelled_by_client]) }
  scope :is_planned, -> { where(status: [:planned]) }
  scope :confirmed_or_planned, -> { where(status: [:confirmed, :confirmed_by_client, :planned]) }

  def happened
    if status == 'confirmed_by_client' || status == 'confirmed'
      true
    elsif status == 'not_attended' || status == 'rejected_by_us' || status == 'cancelled_by_client' || status == 'planned'
      false
    end
  end

  def color
    if status == 'confirmed_by_client' || status == 'confirmed'
      'green'
    elsif status == 'not_attended'
      'red'
    elsif status == 'rejected_by_us' || status == 'cancelled_by_client'
      'grey'
    elsif status == 'planned'
      'blue'
    else
      'black'
    end
  end

  #console commands to update counters, if needed
  #Client.find_each { |client| Client.reset_counters(client.id, :jobs_count) }
  #Service.find_each { |service| Service.reset_counters(service.id, :jobs_count) }
  #Location.find_each { |location| Location.reset_counters(location.id, :jobs_count) }
  #Employee.find_each { |member| Employee.reset_counters(member.id, :jobs_count) }
  #ServiceCategory.find_each { |service_category| ServiceCategory.reset_counters(service_category.id, :services_count) }
  #Client.find_each { |client| Client.reset_counters(client.id, :comments_count) }
  #Location.find_each { |location| Location.reset_counters(location.id, :workplaces_count) }

  validates :client, :starts_at, :status, :service, :location, :member,
            :service_name, :service_duration, :service_member_percent, :client_price,
             :member_price, presence: true
  validates :description, length: { maximum: 500 }

  ############GEM VALIDATES_TIMELINESS############
  #validates_time :starts_at, :between => ['9:00am', '5:00pm'] # On or after 9:00AM and on or before 5:00PM
  validates_date :starts_at, :on => :create, :on_or_after => :today # See Restriction Shorthand.
  #validates_date :starts_at, :on_or_after => lambda { Date.current }
  #validates :starts_at, :timeliness => {:on_or_after => lambda { Date.current }, :type => :date}
  ############GEM VALIDATES_OVERLAP############
  #cancelled Jobs should not be taken in account
  #validates :starts_at, :ends_at, :overlap => {:query_options => {:is_cancelled => nil}}

  validates :starts_at, :ends_at, overlap: {:scope => "member_id", :exclude_edges => ["starts_at", "ends_at"], :load_overlapped => true}

  def overlapped_records
    @overlapped_records || []
  end
  ############GEM MONEY############
  monetize :client_price, as: :client_price_cents
  monetize :member_price, as: :member_price_cents
  monetize :client_due_price, as: :client_due_price_cents
  monetize :member_due_price, as: :member_due_price_cents

  def to_s
    id
  end

  def full_name
    "#{service} for #{client} at #{starts_at} by #{member}"
  end

  protected

  def touch_associations
    client.update_balance
    member.update_balance
    location.update_balance
  end

  def update_associated_columns
    update_column :service_name, (service.name)
    update_column :service_description, (service.description)
    update_column :service_duration, (service.duration)
    update_column :client_price, (service.client_price)
    update_column :member_price, (service.member_price)
    update_column :ends_at, (starts_at + service_duration*60)
    update_column :service_member_percent, (service.member_percent)
  end

  def update_ends_at
    update_column :ends_at, (starts_at + service_duration*60)
  end

  def update_due_prices
    if self.happened
      update_column :client_due_price, (client_price)
      update_column :member_due_price, (member_price)
    else
      update_column :client_due_price, (0)
      update_column :member_due_price, (0)
    end
  end

end
