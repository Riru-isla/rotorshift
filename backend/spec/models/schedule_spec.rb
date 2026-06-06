require "rails_helper"

RSpec.describe Schedule, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:published_by).optional }
    it { is_expected.to have_many(:schedule_entries).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:schedule) }

    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_numericality_of(:year).is_greater_than(2000) }
    it { is_expected.to validate_presence_of(:month) }
    it { is_expected.to validate_inclusion_of(:month).in_range(1..12) }

    it "enforces uniqueness of year+month per organization" do
      org = create(:organization)
      create(:schedule, organization: org, year: 2026, month: 7)
      duplicate = build(:schedule, organization: org, year: 2026, month: 7)
      expect(duplicate).not_to be_valid
    end

    it "allows the same year+month for different organizations" do
      create(:schedule, year: 2026, month: 7)
      other = build(:schedule, year: 2026, month: 7)
      expect(other).to be_valid
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(draft: 0, published: 1, archived: 2) }
  end

  describe "defaults" do
    it "defaults status to draft" do
      schedule = Schedule.new
      expect(schedule.status).to eq("draft")
    end
  end
end
