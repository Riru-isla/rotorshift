require "rails_helper"

RSpec.describe StaffingRequirement, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:minimum_pilots) }
    it { is_expected.to validate_numericality_of(:minimum_pilots).is_greater_than(0) }

    it "is invalid when end_date is before start_date" do
      req = build(:staffing_requirement, start_date: Date.current + 10.days, end_date: Date.current + 5.days)
      expect(req).not_to be_valid
      expect(req.errors[:end_date]).to include("must be on or after start date")
    end
  end
end
