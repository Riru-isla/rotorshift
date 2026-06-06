require "rails_helper"

RSpec.describe ScheduleEntry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:schedule) }
    it { is_expected.to belong_to(:pilot_profile) }
  end

  describe "validations" do
    subject { build(:schedule_entry) }

    it { is_expected.to validate_presence_of(:date) }

    it "enforces one entry per pilot per day per schedule" do
      schedule = create(:schedule)
      profile = create(:pilot_profile)
      date = Date.new(2026, 7, 1)
      create(:schedule_entry, schedule: schedule, pilot_profile: profile, date: date)
      duplicate = build(:schedule_entry, schedule: schedule, pilot_profile: profile, date: date)
      expect(duplicate).not_to be_valid
    end
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:entry_type)
        .with_values(on_duty: 0, off_duty: 1, training: 2, holiday: 3, vacation: 4, unavailable: 5)
    end
  end
end
