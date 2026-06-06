require "rails_helper"

RSpec.describe ShiftPattern, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:pilot_profiles).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:shift_pattern) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id) }
    it { is_expected.to validate_presence_of(:days_on) }
    it { is_expected.to validate_numericality_of(:days_on).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:days_off) }
    it { is_expected.to validate_numericality_of(:days_off).is_greater_than(0) }
  end

  describe "scopes" do
    it ".active returns only active patterns" do
      org = create(:organization)
      active = create(:shift_pattern, organization: org, active: true)
      create(:shift_pattern, organization: org, active: false)

      expect(ShiftPattern.active).to eq([active])
    end
  end

  describe "#cycle_length" do
    it "returns the sum of days_on and days_off" do
      pattern = build(:shift_pattern, days_on: 7, days_off: 7)
      expect(pattern.cycle_length).to eq(14)
    end
  end

  describe "#to_s" do
    it "returns the pattern as a readable string" do
      pattern = build(:shift_pattern, days_on: 7, days_off: 7)
      expect(pattern.to_s).to eq("7/7")
    end
  end
end
