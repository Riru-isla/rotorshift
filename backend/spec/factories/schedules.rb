FactoryBot.define do
  factory :schedule do
    organization
    year { Date.current.year }
    month { Date.current.month }
    status { :draft }

    trait :published do
      status { :published }
      published_at { Time.current }
      published_by { association :user }
    end
  end
end
