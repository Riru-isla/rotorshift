FactoryBot.define do
  factory :vacation_request do
    pilot_profile
    start_date { 1.month.from_now.to_date }
    end_date { 1.month.from_now.to_date + 5.days }
    status { :pending }
    reason { "Family vacation" }

    trait :approved do
      status { :approved }
      reviewed_by { association :user }
      reviewed_at { Time.current }
    end

    trait :denied do
      status { :denied }
      reviewed_by { association :user }
      reviewed_at { Time.current }
      review_notes { "Insufficient coverage" }
    end
  end
end
