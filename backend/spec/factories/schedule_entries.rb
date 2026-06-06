FactoryBot.define do
  factory :schedule_entry do
    schedule
    pilot_profile
    sequence(:date) { |n| Date.new(schedule&.year || 2026, schedule&.month || 1, 1) + (n % 28).days }
    entry_type { :on_duty }
  end
end
