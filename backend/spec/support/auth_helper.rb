module AuthHelper
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    { "Authorization" => "Bearer #{token}" }
  end

  def auth_get(path, user:, **opts)
    get path, headers: auth_headers(user), as: :json, **opts
  end

  def auth_post(path, user:, params: {}, **opts)
    post path, headers: auth_headers(user), params: params, as: :json, **opts
  end

  def auth_patch(path, user:, params: {}, **opts)
    patch path, headers: auth_headers(user), params: params, as: :json, **opts
  end

  def auth_delete(path, user:, **opts)
    delete path, headers: auth_headers(user), as: :json, **opts
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
