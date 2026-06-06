class StaffingRequirement < ApplicationRecord
  belongs_to :organization

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :minimum_pilots, presence: true, numericality: { greater_than: 0 }
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
end
