require "rails_helper"

RSpec.describe VacationRequest, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:pilot_profile) }
    it { is_expected.to belong_to(:reviewed_by).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    it "is invalid when end_date is before start_date" do
      request = build(:vacation_request, start_date: Date.current + 10.days, end_date: Date.current + 5.days)
      expect(request).not_to be_valid
      expect(request.errors[:end_date]).to include("must be on or after start date")
    end

    it "is valid when end_date equals start_date" do
      date = Date.current + 10.days
      request = build(:vacation_request, start_date: date, end_date: date)
      expect(request).to be_valid
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, approved: 1, denied: 2, cancelled: 3) }
  end

  describe "scopes" do
    it ".active returns pending and approved requests" do
      pending_req = create(:vacation_request, status: :pending)
      approved_req = create(:vacation_request, :approved)
      create(:vacation_request, :denied)
      create(:vacation_request, status: :cancelled)

      expect(VacationRequest.active).to contain_exactly(pending_req, approved_req)
    end
  end

  describe "#duration_days" do
    it "returns the number of days including start and end" do
      request = build(:vacation_request, start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 7, 5))
      expect(request.duration_days).to eq(5)
    end

    it "returns 1 for a single-day request" do
      date = Date.new(2026, 7, 1)
      request = build(:vacation_request, start_date: date, end_date: date)
      expect(request.duration_days).to eq(1)
    end
  end

  describe "defaults" do
    it "defaults status to pending" do
      request = VacationRequest.new
      expect(request.status).to eq("pending")
    end
  end
end
