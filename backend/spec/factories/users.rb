FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    organization

    trait :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    trait :manager do
      after(:create) { |user| user.add_role(:manager) }
    end
  end
end
