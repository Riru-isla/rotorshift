FactoryBot.define do
  factory :unavailable_day do
    pilot_profile
    sequence(:date) { |n| Date.current + n.days }
    reason { "Personal commitment" }
  end
end
