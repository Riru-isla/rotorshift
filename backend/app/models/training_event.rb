class TrainingEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :pilot_profile

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_after_starts

  scope :mandatory, -> { where(mandatory: true) }

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end
end
