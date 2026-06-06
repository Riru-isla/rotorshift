class ScheduleEntry < ApplicationRecord
  belongs_to :schedule
  belongs_to :pilot_profile

  enum :entry_type, { on_duty: 0, off_duty: 1, training: 2, holiday: 3, vacation: 4, unavailable: 5 }

  validates :date, presence: true
  validates :date, uniqueness: { scope: [:schedule_id, :pilot_profile_id] }
end
