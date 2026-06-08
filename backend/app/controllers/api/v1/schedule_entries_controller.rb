class Api::V1::ScheduleEntriesController < Api::V1::BaseController
  before_action :set_schedule

  def index
    entries = @schedule.schedule_entries
      .includes(pilot_profile: :user)
      .order(:date, :pilot_profile_id)

    if params[:pilot_profile_id]
      entries = entries.where(pilot_profile_id: params[:pilot_profile_id])
    end

    render json: entries.map { |e| entry_payload(e) }
  end

  def create
    entry = @schedule.schedule_entries.build(entry_params)

    if entry.save
      render json: entry_payload(entry), status: :created
    else
      render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    entry = @schedule.schedule_entries.find(params[:id])

    if entry.update(entry_params)
      render json: entry_payload(entry)
    else
      render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    entry = @schedule.schedule_entries.find(params[:id])
    entry.destroy
    head :no_content
  end

  private

  def set_schedule
    @schedule = current_organization.schedules.find(params[:schedule_id])
  end

  def entry_params
    params.permit(:pilot_profile_id, :date, :entry_type, :notes)
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
