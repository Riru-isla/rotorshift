FactoryBot.define do
  factory :shift_pattern do
    organization
    sequence(:name) { |n| "Pattern #{n}" }
    days_on { 7 }
    days_off { 7 }
    active { true }
  end
end
