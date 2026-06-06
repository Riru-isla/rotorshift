class UnavailableDay < ApplicationRecord
  belongs_to :pilot_profile

  validates :date, presence: true, uniqueness: { scope: :pilot_profile_id }
end
