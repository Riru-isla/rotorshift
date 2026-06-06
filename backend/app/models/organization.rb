class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :shift_patterns, dependent: :destroy
  has_many :pilot_profiles, through: :users
  has_many :holidays, dependent: :destroy
  has_many :training_events, dependent: :destroy
  has_many :staffing_requirements, dependent: :destroy
  has_many :schedules, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :timezone, presence: true

  scope :active, -> { where(active: true) }
end
