class VacationRequest < ApplicationRecord
  belongs_to :pilot_profile
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: 0, approved: 1, denied: 2, cancelled: 3 }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  scope :active, -> { where(status: [:pending, :approved]) }

  def duration_days
    (end_date - start_date).to_i + 1
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
end
