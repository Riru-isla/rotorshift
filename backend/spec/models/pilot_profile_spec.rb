require "rails_helper"

RSpec.describe PilotProfile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:shift_pattern) }
    it { is_expected.to have_many(:training_events).dependent(:destroy) }
    it { is_expected.to have_many(:unavailable_days).dependent(:destroy) }
    it { is_expected.to have_many(:vacation_requests).dependent(:destroy) }
    it { is_expected.to have_many(:schedule_entries).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:pilot_profile) }

    it { is_expected.to validate_uniqueness_of(:user_id) }
    it { is_expected.to validate_presence_of(:rotation_start_date) }
    it { is_expected.to validate_uniqueness_of(:license_number).allow_nil }
  end

  describe "scopes" do
    it ".active returns only active profiles" do
      active = create(:pilot_profile, active: true)
      create(:pilot_profile, active: false)

      expect(PilotProfile.active).to eq([active])
    end
  end

  describe "delegation" do
    it "delegates full_name to user" do
      profile = create(:pilot_profile)
      expect(profile.full_name).to eq(profile.user.full_name)
    end

    it "delegates email to user" do
      profile = create(:pilot_profile)
      expect(profile.email).to eq(profile.user.email)
    end

    it "delegates organization to user" do
      profile = create(:pilot_profile)
      expect(profile.organization).to eq(profile.user.organization)
    end
  end

  describe "uniqueness" do
    it "prevents two profiles for the same user" do
      user = create(:user)
      create(:pilot_profile, user: user)
      duplicate = build(:pilot_profile, user: user)
      expect(duplicate).not_to be_valid
    end
  end
end
