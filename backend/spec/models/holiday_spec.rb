require "rails_helper"

RSpec.describe Holiday, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    subject { build(:holiday) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:organization_id) }
  end

  describe "uniqueness" do
    it "prevents duplicate dates within the same organization" do
      org = create(:organization)
      create(:holiday, organization: org, date: Date.new(2026, 12, 25))
      duplicate = build(:holiday, organization: org, date: Date.new(2026, 12, 25))
      expect(duplicate).not_to be_valid
    end

    it "allows the same date in different organizations" do
      date = Date.new(2026, 12, 25)
      create(:holiday, date: date)
      other = build(:holiday, date: date)
      expect(other).to be_valid
    end
  end
end
