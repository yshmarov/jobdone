class Job < ApplicationRecord
  #-----------------------gem milia-------------------#
  acts_as_tenant
  #-----------------------relationships-------------------#
  #counter_cache for job_count
  #touch to calculate balance
  belongs_to :member, touch: true, counter_cache: true
  belongs_to :service, counter_cache: true
  #touch to calculate duration and total_client_price????
  belongs_to :event, touch: true, counter_cache: true
  #-----------------------validation-------------------#
  #service_duration
  #service_member_percent
  #service_client_price
  #client_price
  #member_price
  #client_due_price
  #member_due_price
  #add_amount
  #production_cost
  validates :event, :service_id, :member,
            :service_duration, :service_member_percent, :service_client_price,
            :client_price, :member_price,
            :client_due_price, :member_due_price, 
            :add_amount, :production_cost, presence: true
  validates :slug, uniqueness: true
  validates :slug, uniqueness: { case_sensitive: false }
  #-----------------------gem public_activity-------------------#
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked tenant_id: Proc.new{ Tenant.current_tenant.id }
  #-----------------------gem friendly_id-------------------#
  extend FriendlyId
  friendly_id :generated_slug, use: :slugged
  def generated_slug
    require 'securerandom' 
    @random_slug ||= persisted? ? friendly_id : SecureRandom.hex(15) 
  end
  #friendly_id :full_name, use: :slugged
  #def full_name
  #  "#{created_at} #{service} for #{event.client} at #{event.starts_at} by #{member}"
  #end
  def to_s
    if slug.present?; slug; else id; end
  end
  #-----------------------gem money-------------------#
  monetize :service_client_price, as: :service_client_price_cents

  monetize :client_price, as: :client_price_cents
  monetize :member_price, as: :member_price_cents

  monetize :client_due_price, as: :client_due_price_cents
  monetize :member_due_price, as: :member_due_price_cents

  monetize :add_amount, as: :add_amount_cents
  monetize :production_cost, as: :production_cost_cents
  #-----------------------callbacks-------------------#
  #after_touch :update_due_prices
  #after_save :update_service_details do event.update_client_price end

  after_save do
  	#save_service_details. not only after_create because a service can be changed in a Job. But than price is also changed! 
  	#So should be like "if same service_id - don't run this. Or make service_id uneditable in a Job?"
    update_column :service_duration, (service.duration) #for calculating event duration OK
    update_column :service_client_price, (service.client_price) #client price calculation OK
    update_column :service_member_percent, (service.member_percent) #member price calculation OK
  end

  after_save do
  	#calculate_prices. OK
    update_column :client_price, (service_client_price + add_amount)
    update_column :member_price, ( (client_price - production_cost) * service_member_percent / 100 )
  end

  #private

  def update_due_prices #event after_save callback
  	#update_due_prices
    if event.confirmed? || event.no_show_refunded?
      update_column :client_due_price, (client_price)
      update_column :member_due_price, (member_price)
    else
      update_column :client_due_price, (0)
      update_column :member_due_price, (0)
    end
  end
end