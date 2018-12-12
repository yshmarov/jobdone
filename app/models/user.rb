class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_universal_and_determines_account
  has_one :member, :dependent => :destroy
  #belongs_to :invitor, class_name: 'Employee', foreign_key: :invited_by_id, required: false

  rolify

  #include PublicActivity::Model
  #tracked only: :create, owner: :itself

  after_create :assign_default_role
  #after_initialize :assign_default_role

  scope :online, lambda{ where("updated_at > ?", 10.minutes.ago) }

  def online?
    updated_at > 10.minutes.ago
  end

  def to_s
    member.to_s
  end

  private

  def assign_default_role
    self.add_role(:specialist) if self.roles.blank?
  end

end
