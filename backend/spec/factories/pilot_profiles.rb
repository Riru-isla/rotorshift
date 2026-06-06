FactoryBot.define do
  factory :pilot_profile do
    user
    shift_pattern
    rotation_start_date { Date.current }
    active { true }
    sequence(:license_number) { |n| "LIC-#{n.to_s.rjust(5, '0')}" }

    after(:build) do |profile|
      profile.user.organization ||= profile.shift_pattern.organization
    end
  end
end
