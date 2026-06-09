require "rails_helper"

RSpec.describe "Api::V1::PilotProfiles", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, organization: organization) }
  let(:shift_pattern) { create(:shift_pattern, organization: organization) }

  describe "GET /api/v1/pilot_profiles" do
    it "returns all pilots for the organization" do
      3.times { create(:pilot_profile, shift_pattern: shift_pattern, user: create(:user, organization: organization)) }
      create(:pilot_profile) # different org

      auth_get "/api/v1/pilot_profiles", user: user

      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(3)
    end

    it "includes both active and inactive pilots" do
      create(:pilot_profile, shift_pattern: shift_pattern, user: create(:user, organization: organization), active: true)
      create(:pilot_profile, shift_pattern: shift_pattern, user: create(:user, organization: organization), active: false)

      auth_get "/api/v1/pilot_profiles", user: user

      expect(parsed_body.size).to eq(2)
    end

    it "returns shift_pattern_id and shift_pattern string" do
      create(:pilot_profile, shift_pattern: shift_pattern, user: create(:user, organization: organization))

      auth_get "/api/v1/pilot_profiles", user: user

      pilot = parsed_body.first
      expect(pilot["shift_pattern_id"]).to eq(shift_pattern.id)
      expect(pilot["shift_pattern"]).to eq(shift_pattern.to_s)
    end
  end

  describe "GET /api/v1/pilot_profiles/:id" do
    it "returns a single pilot" do
      pilot_profile = create(:pilot_profile, shift_pattern: shift_pattern, user: create(:user, organization: organization))

      auth_get "/api/v1/pilot_profiles/#{pilot_profile.id}", user: user

      expect(response).to have_http_status(:ok)
      expect(parsed_body["id"]).to eq(pilot_profile.id)
      expect(parsed_body["name"]).to eq(pilot_profile.full_name)
    end

    it "returns 404 for another org's pilot" do
      other_pilot = create(:pilot_profile)

      auth_get "/api/v1/pilot_profiles/#{other_pilot.id}", user: user

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/pilot_profiles/:id" do
    let(:pilot_profile) { create(:pilot_profile, shift_pattern: shift_pattern, user: create(:user, organization: organization)) }

    it "updates the shift pattern assignment" do
      new_pattern = create(:shift_pattern, organization: organization, name: "15/15", days_on: 15, days_off: 15)

      auth_patch "/api/v1/pilot_profiles/#{pilot_profile.id}", user: user,
                 params: { shift_pattern_id: new_pattern.id }

      expect(response).to have_http_status(:ok)
      expect(parsed_body["shift_pattern_id"]).to eq(new_pattern.id)
      expect(parsed_body["shift_pattern"]).to eq("15/15")
    end

    it "updates the rotation start date" do
      auth_patch "/api/v1/pilot_profiles/#{pilot_profile.id}", user: user,
                 params: { rotation_start_date: "2026-03-01" }

      expect(response).to have_http_status(:ok)
      expect(parsed_body["rotation_start_date"]).to eq("2026-03-01")
    end

    it "toggles active status" do
      auth_patch "/api/v1/pilot_profiles/#{pilot_profile.id}", user: user,
                 params: { active: false }

      expect(response).to have_http_status(:ok)
      expect(parsed_body["active"]).to be false
    end

    it "returns 404 for another org's pilot" do
      other_pilot = create(:pilot_profile)

      auth_patch "/api/v1/pilot_profiles/#{other_pilot.id}", user: user,
                 params: { active: false }

      expect(response).to have_http_status(:not_found)
    end
  end

  def parsed_body
    JSON.parse(response.body)
  end
end
