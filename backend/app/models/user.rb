class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :organization, optional: true
  has_one :pilot_profile, dependent: :destroy

  has_many :reviewed_vacation_requests, class_name: "VacationRequest", foreign_key: :reviewed_by_id
  has_many :published_schedules, class_name: "Schedule", foreign_key: :published_by_id

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def pilot?
    pilot_profile.present?
  end
end
