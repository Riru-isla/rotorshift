require "rails_helper"

RSpec.describe UnavailableDay, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:pilot_profile) }
  end

  describe "validations" do
    subject { build(:unavailable_day) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:pilot_profile_id) }
  end

  describe "uniqueness" do
    it "prevents duplicate dates for the same pilot" do
      profile = create(:pilot_profile)
      date = Date.current + 10.days
      create(:unavailable_day, pilot_profile: profile, date: date)
      duplicate = build(:unavailable_day, pilot_profile: profile, date: date)
      expect(duplicate).not_to be_valid
    end

    it "allows the same date for different pilots" do
      date = Date.current + 10.days
      create(:unavailable_day, date: date)
      other = build(:unavailable_day, date: date)
      expect(other).to be_valid
    end
  end
end
