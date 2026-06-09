class Api::V1::SchedulesController < Api::V1::BaseController
  before_action :set_schedule, only: [:show, :update, :publish, :unpublish, :destroy]

  def index
    schedules = current_organization.schedules.order(year: :asc, month: :asc, created_at: :desc)
    render json: schedules.map { |s| schedule_payload(s) }
  end

  def show
    entries = @schedule.schedule_entries
      .includes(pilot_profile: :user)
      .order(:date, :pilot_profile_id)

    render json: {
      schedule: schedule_payload(@schedule),
      entries: entries.map { |e| entry_payload(e) }
    }
  end

  def create
    schedule = current_organization.schedules.build(schedule_params)

    if schedule.save
      if params[:auto_generate]
        ScheduleGenerator.new(
          schedule: schedule,
          minimum_active: params[:minimum_active].to_i,
          minimum_on_hold: params[:minimum_on_hold].to_i
        ).generate
      end

      render json: {
        schedule: schedule_payload(schedule.reload),
        entries: schedule.schedule_entries.includes(pilot_profile: :user).map { |e| entry_payload(e) }
      }, status: :created
    else
      render json: { errors: schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @schedule.update(schedule_params)
      render json: { schedule: schedule_payload(@schedule) }
    else
      render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def publish
    if @schedule.update(status: :published, published_at: Time.current, published_by: current_user)
      render json: { schedule: schedule_payload(@schedule) }
    else
      render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def unpublish
    today = Date.current
    if !@schedule.published?
      render json: { errors: ["Only published schedules can be unpublished"] }, status: :unprocessable_entity
    elsif @schedule.year < today.year || (@schedule.year == today.year && @schedule.month <= today.month)
      render json: { errors: ["Cannot unpublish current or past schedules"] }, status: :unprocessable_entity
    else
      @schedule.update!(status: :draft, published_at: nil, published_by: nil)
      render json: { schedule: schedule_payload(@schedule) }
    end
  end

  def destroy
    if @schedule.draft?
      @schedule.destroy!
      head :no_content
    else
      render json: { errors: ["Only draft schedules can be deleted"] }, status: :unprocessable_entity
    end
  end

  private

  def set_schedule
    @schedule = current_organization.schedules.find(params[:id])
  end

  def schedule_params
    params.permit(:year, :month, :name, :description)
  end

  def schedule_payload(schedule)
    {
      id: schedule.id,
      name: schedule.name,
      description: schedule.description,
      year: schedule.year,
      month: schedule.month,
      status: schedule.status,
      published_at: schedule.published_at,
      published_by: schedule.published_by&.full_name,
      created_at: schedule.created_at
    }
  end

  def entry_payload(entry)
    {
      id: entry.id,
      date: entry.date,
      entry_type: entry.entry_type,
      notes: entry.notes,
      pilot: {
        id: entry.pilot_profile.id,
        name: entry.pilot_profile.full_name,
        license_number: entry.pilot_profile.license_number
      }
    }
  end
end
