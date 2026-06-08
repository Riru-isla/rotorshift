class ScheduleGenerator
  attr_reader :schedule, :organization, :minimum_active, :minimum_on_hold

  def initialize(schedule:, minimum_active:, minimum_on_hold: 0)
    @schedule = schedule
    @organization = schedule.organization
    @minimum_active = minimum_active
    @minimum_on_hold = minimum_on_hold
  end

  def generate
    schedule.schedule_entries.destroy_all

    entries = []
    dates.each do |date|
      pilots.each do |pilot|
        entry_type = determine_entry_type(pilot, date)
        entries << {
          schedule_id: schedule.id,
          pilot_profile_id: pilot.id,
          date: date,
          entry_type: entry_type,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end

    ScheduleEntry.insert_all(entries) if entries.any?
    balance_schedule
    schedule.reload
  end

  private

  def dates
    @dates ||= begin
      start_date = Date.new(schedule.year, schedule.month, 1)
      end_date = start_date.end_of_month
      (start_date..end_date).to_a
    end
  end

  def pilots
    @pilots ||= organization.pilot_profiles.active.includes(:shift_pattern, :unavailable_days, :vacation_requests).to_a
  end

  def holidays
    @holidays ||= organization.holidays.where(date: dates).pluck(:date).to_set
  end

  def determine_entry_type(pilot, date)
    return :unavailable if unavailable?(pilot, date)
    return :vacation if on_approved_vacation?(pilot, date)
    return :holiday if holidays.include?(date)
    return :training if has_training?(pilot, date)

    rotation_status(pilot, date)
  end

  def unavailable?(pilot, date)
    pilot.unavailable_days.any? { |ud| ud.date == date }
  end

  def on_approved_vacation?(pilot, date)
    pilot.vacation_requests.approved.any? { |vr| date >= vr.start_date && date <= vr.end_date }
  end

  def has_training?(pilot, date)
    pilot.training_events.any? { |te| date >= te.starts_at.to_date && date <= te.ends_at.to_date }
  end

  def rotation_status(pilot, date)
    pattern = pilot.shift_pattern
    days_since_start = (date - pilot.rotation_start_date).to_i
    cycle_day = days_since_start % pattern.cycle_length

    cycle_day < pattern.days_on ? :on_duty : :off_duty
  end

  def balance_schedule
    dates.each do |date|
      day_entries = schedule.schedule_entries.where(date: date).includes(:pilot_profile)
      active_entries = day_entries.where(entry_type: :on_duty)
      off_entries = day_entries.where(entry_type: :off_duty)

      deficit = minimum_active - active_entries.count

      if deficit > 0
        off_entries.limit(deficit).each do |entry|
          entry.update(entry_type: :on_duty, notes: "Moved to cover minimum staffing")
        end
      end
    end
  end
end
