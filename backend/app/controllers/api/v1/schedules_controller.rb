class Api::V1::SchedulesController < Api::V1::BaseController
  before_action :set_schedule, only: [:show, :update, :publish]

  def index
    schedules = current_organization.schedules.order(year: :desc, month: :desc)
    render json: schedules.as_json(methods: [:status])
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
    @schedule.update!(status: :published, published_at: Time.current, published_by: current_user)
    render json: { schedule: schedule_payload(@schedule) }
  end

  private

  def set_schedule
    @schedule = current_organization.schedules.find(params[:id])
  end

  def schedule_params
    params.permit(:year, :month)
  end

  def schedule_payload(schedule)
    {
      id: schedule.id,
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
