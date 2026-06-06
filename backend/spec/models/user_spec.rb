require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization).optional }
    it { is_expected.to have_one(:pilot_profile).dependent(:destroy) }
    it { is_expected.to have_many(:reviewed_vacation_requests) }
    it { is_expected.to have_many(:published_schedules) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end

  describe "#pilot?" do
    it "returns true when user has a pilot profile" do
      user = create(:user)
      create(:pilot_profile, user: user)
      expect(user.pilot?).to be true
    end

    it "returns false when user has no pilot profile" do
      user = create(:user)
      expect(user.pilot?).to be false
    end
  end

  describe "roles" do
    it "can be assigned roles via rolify" do
      user = create(:user)
      user.add_role(:admin)
      expect(user.has_role?(:admin)).to be true
    end

    it "can have scoped roles" do
      user = create(:user)
      org = create(:organization)
      user.add_role(:manager, org)
      expect(user.has_role?(:manager, org)).to be true
      expect(user.has_role?(:manager)).to be false
    end
  end
end
