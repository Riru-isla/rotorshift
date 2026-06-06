FactoryBot.define do
  factory :staffing_requirement do
    organization
    start_date { Date.current.beginning_of_month }
    end_date { Date.current.end_of_month }
    minimum_pilots { 3 }
  end
end
