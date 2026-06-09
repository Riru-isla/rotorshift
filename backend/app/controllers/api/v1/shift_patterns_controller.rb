class Api::V1::ShiftPatternsController < Api::V1::BaseController
  before_action :set_shift_pattern, only: [:show, :update, :destroy]

  def index
    patterns = current_organization.shift_patterns.order(:name)
    render json: patterns.map { |p| pattern_payload(p) }
  end

  def show
    render json: pattern_payload(@shift_pattern)
  end

  def create
    pattern = current_organization.shift_patterns.build(shift_pattern_params)

    if pattern.save
      render json: pattern_payload(pattern), status: :created
    else
      render json: { errors: pattern.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @shift_pattern.update(shift_pattern_params)
      render json: pattern_payload(@shift_pattern)
    else
      render json: { errors: @shift_pattern.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @shift_pattern.destroy
      head :no_content
    else
      render json: { errors: ["Cannot delete pattern while pilots are assigned to it"] }, status: :unprocessable_entity
    end
  end

  private

  def set_shift_pattern
    @shift_pattern = current_organization.shift_patterns.find(params[:id])
  end

  def shift_pattern_params
    params.permit(:name, :days_on, :days_off, :active)
  end

  def pattern_payload(pattern)
    {
      id: pattern.id,
      name: pattern.name,
      days_on: pattern.days_on,
      days_off: pattern.days_off,
      cycle_length: pattern.cycle_length,
      active: pattern.active,
      pilot_count: pattern.pilot_profiles.count
    }
  end
end
