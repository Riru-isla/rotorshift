FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    sequence(:code) { |n| "ORG#{n}" }
    timezone { "UTC" }
    country { Faker::Address.country_code }
    active { true }
  end
end
