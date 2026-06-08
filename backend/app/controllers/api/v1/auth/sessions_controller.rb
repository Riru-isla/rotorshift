class Api::V1::Auth::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      user: user_payload(resource),
      token: request.env["warden-jwt_auth.token"]
    }, status: :ok
  end

  def respond_to_on_destroy(_resource_or_scope = nil)
    render json: { message: "Signed out" }, status: :ok
  end

  def user_payload(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      organization_id: user.organization_id,
      roles: user.roles.pluck(:name)
    }
  end
end
