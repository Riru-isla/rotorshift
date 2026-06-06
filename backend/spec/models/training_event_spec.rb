require "rails_helper"

RSpec.describe TrainingEvent, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:pilot_profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }

    it "is invalid when ends_at is before starts_at" do
      event = build(:training_event, starts_at: 2.hours.from_now, ends_at: 1.hour.from_now)
      expect(event).not_to be_valid
      expect(event.errors[:ends_at]).to include("must be after start time")
    end

    it "is invalid when ends_at equals starts_at" do
      time = 1.hour.from_now
      event = build(:training_event, starts_at: time, ends_at: time)
      expect(event).not_to be_valid
    end

    it "is valid when ends_at is after starts_at" do
      event = build(:training_event, starts_at: 1.hour.from_now, ends_at: 2.hours.from_now)
      expect(event).to be_valid
    end
  end

  describe "scopes" do
    it ".mandatory returns only mandatory events" do
      mandatory = create(:training_event, mandatory: true)
      create(:training_event, mandatory: false)

      expect(TrainingEvent.mandatory).to eq([mandatory])
    end
  end
end
