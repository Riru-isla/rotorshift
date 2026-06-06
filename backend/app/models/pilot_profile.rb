class PilotProfile < ApplicationRecord
  belongs_to :user
  belongs_to :shift_pattern

  has_many :training_events, dependent: :destroy
  has_many :unavailable_days, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :schedule_entries, dependent: :destroy

  validates :user_id, uniqueness: true
  validates :rotation_start_date, presence: true
  validates :license_number, uniqueness: true, allow_nil: true

  scope :active, -> { where(active: true) }

  delegate :organization, :full_name, :email, to: :user
end
