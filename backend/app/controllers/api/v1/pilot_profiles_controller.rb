class Api::V1::PilotProfilesController < Api::V1::BaseController
  before_action :set_pilot, only: [:show, :update]

  def index
    pilots = current_organization.pilot_profiles.includes(:user, :shift_pattern)

    render json: pilots.map { |p| pilot_payload(p) }
  end

  def show
    render json: pilot_payload(@pilot)
  end

  def update
    if @pilot.update(pilot_params)
      render json: pilot_payload(@pilot.reload)
    else
      render json: { errors: @pilot.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_pilot
    @pilot = current_organization.pilot_profiles.find(params[:id])
  end

  def pilot_params
    params.permit(:shift_pattern_id, :rotation_start_date, :active)
  end

  def pilot_payload(pilot)
    {
      id: pilot.id,
      name: pilot.full_name,
      email: pilot.email,
      license_number: pilot.license_number,
      shift_pattern_id: pilot.shift_pattern_id,
      shift_pattern: pilot.shift_pattern.to_s,
      rotation_start_date: pilot.rotation_start_date,
      active: pilot.active
    }
  end
end
