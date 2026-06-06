FactoryBot.define do
  factory :holiday do
    organization
    name { Faker::Lorem.words(number: 2).join(" ").capitalize }
    sequence(:date) { |n| Date.new(2026, 1, 1) + n.days }
    recurring { false }
  end
end
