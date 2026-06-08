class Api::V1::PilotProfilesController < Api::V1::BaseController
  def index
    pilots = current_organization.pilot_profiles.active.includes(:user, :shift_pattern)

    render json: pilots.map { |p| pilot_payload(p) }
  end

  def show
    pilot = current_organization.pilot_profiles.find(params[:id])

    render json: pilot_payload(pilot)
  end

  private

  def pilot_payload(pilot)
    {
      id: pilot.id,
      name: pilot.full_name,
      email: pilot.email,
      license_number: pilot.license_number,
      shift_pattern: pilot.shift_pattern.to_s,
      rotation_start_date: pilot.rotation_start_date,
      active: pilot.active
    }
  end
end
