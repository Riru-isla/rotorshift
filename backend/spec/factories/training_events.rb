FactoryBot.define do
  factory :training_event do
    organization
    pilot_profile
    title { "Simulator Training" }
    starts_at { 1.week.from_now.beginning_of_day + 9.hours }
    ends_at { 1.week.from_now.beginning_of_day + 17.hours }
    mandatory { true }

    after(:build) do |event|
      event.pilot_profile.user.organization ||= event.organization
    end
  end
end
