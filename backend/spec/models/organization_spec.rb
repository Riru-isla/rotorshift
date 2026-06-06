require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:shift_patterns).dependent(:destroy) }
    it { is_expected.to have_many(:pilot_profiles).through(:users) }
    it { is_expected.to have_many(:holidays).dependent(:destroy) }
    it { is_expected.to have_many(:training_events).dependent(:destroy) }
    it { is_expected.to have_many(:staffing_requirements).dependent(:destroy) }
    it { is_expected.to have_many(:schedules).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:organization) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }
    it { is_expected.to validate_presence_of(:timezone) }
  end

  describe "scopes" do
    it ".active returns only active organizations" do
      active = create(:organization, active: true)
      create(:organization, active: false)

      expect(Organization.active).to eq([active])
    end
  end

  describe "defaults" do
    it "defaults active to true" do
      org = Organization.new
      expect(org.active).to be true
    end

    it "defaults timezone to UTC" do
      org = Organization.new
      expect(org.timezone).to eq("UTC")
    end
  end
end
