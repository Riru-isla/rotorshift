class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  def current_organization
    current_user.organization
  end
end
