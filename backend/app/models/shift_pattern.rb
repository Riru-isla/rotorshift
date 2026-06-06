class ShiftPattern < ApplicationRecord
  belongs_to :organization
  has_many :pilot_profiles, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :days_on, presence: true, numericality: { greater_than: 0 }
  validates :days_off, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def cycle_length
    days_on + days_off
  end

  def to_s
    "#{days_on}/#{days_off}"
  end
end
