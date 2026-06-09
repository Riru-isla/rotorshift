require "rails_helper"

RSpec.describe "Api::V1::ShiftPatterns", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, organization: organization) }

  describe "GET /api/v1/shift_patterns" do
    it "returns all shift patterns for the organization" do
      create_list(:shift_pattern, 3, organization: organization)
      create(:shift_pattern) # different org

      auth_get "/api/v1/shift_patterns", user: user

      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(3)
    end

    it "includes pilot_count" do
      pattern = create(:shift_pattern, organization: organization)
      create(:pilot_profile, shift_pattern: pattern, user: create(:user, organization: organization))

      auth_get "/api/v1/shift_patterns", user: user

      expect(parsed_body.first["pilot_count"]).to eq(1)
    end
  end

  describe "GET /api/v1/shift_patterns/:id" do
    it "returns the shift pattern" do
      pattern = create(:shift_pattern, organization: organization, name: "15/15", days_on: 15, days_off: 15)

      auth_get "/api/v1/shift_patterns/#{pattern.id}", user: user

      expect(response).to have_http_status(:ok)
      expect(parsed_body["name"]).to eq("15/15")
      expect(parsed_body["days_on"]).to eq(15)
      expect(parsed_body["days_off"]).to eq(15)
      expect(parsed_body["cycle_length"]).to eq(30)
    end

    it "returns 404 for another org's pattern" do
      other_pattern = create(:shift_pattern)

      auth_get "/api/v1/shift_patterns/#{other_pattern.id}", user: user

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/shift_patterns" do
    it "creates a shift pattern" do
      auth_post "/api/v1/shift_patterns", user: user,
                params: { name: "Long rotation", days_on: 14, days_off: 14 }

      expect(response).to have_http_status(:created)
      expect(parsed_body["name"]).to eq("Long rotation")
      expect(parsed_body["days_on"]).to eq(14)
      expect(parsed_body["days_off"]).to eq(14)
      expect(parsed_body["active"]).to be true
    end

    it "rejects duplicate names within the same org" do
      create(:shift_pattern, organization: organization, name: "Standard")

      auth_post "/api/v1/shift_patterns", user: user,
                params: { name: "Standard", days_on: 7, days_off: 7 }

      expect(response).to have_http_status(:unprocessable_content)
      expect(parsed_body["errors"]).to include(a_string_matching(/Name/i))
    end

    it "rejects invalid days" do
      auth_post "/api/v1/shift_patterns", user: user,
                params: { name: "Bad", days_on: 0, days_off: 7 }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/shift_patterns/:id" do
    it "updates the shift pattern" do
      pattern = create(:shift_pattern, organization: organization, days_on: 7, days_off: 7)

      auth_patch "/api/v1/shift_patterns/#{pattern.id}", user: user,
                 params: { days_on: 15, days_off: 15 }

      expect(response).to have_http_status(:ok)
      expect(parsed_body["days_on"]).to eq(15)
      expect(parsed_body["days_off"]).to eq(15)
      expect(parsed_body["cycle_length"]).to eq(30)
    end
  end

  describe "DELETE /api/v1/shift_patterns/:id" do
    it "deletes a pattern with no pilots" do
      pattern = create(:shift_pattern, organization: organization)

      auth_delete "/api/v1/shift_patterns/#{pattern.id}", user: user

      expect(response).to have_http_status(:no_content)
      expect(ShiftPattern.find_by(id: pattern.id)).to be_nil
    end

    it "refuses to delete a pattern with assigned pilots" do
      pattern = create(:shift_pattern, organization: organization)
      create(:pilot_profile, shift_pattern: pattern, user: create(:user, organization: organization))

      auth_delete "/api/v1/shift_patterns/#{pattern.id}", user: user

      expect(response).to have_http_status(:unprocessable_content)
      expect(parsed_body["errors"]).to include(a_string_matching(/Cannot delete/))
    end
  end

  def parsed_body
    JSON.parse(response.body)
  end
end
