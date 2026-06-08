class Api::V1::MeController < Api::V1::BaseController
  def show
    render json: {
      user: {
        id: current_user.id,
        email: current_user.email,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        organization_id: current_user.organization_id,
        roles: current_user.roles.pluck(:name),
        pilot_profile: current_user.pilot_profile&.as_json(only: [:id, :license_number, :active])
      }
    }
  end
end
