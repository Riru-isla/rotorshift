class Holiday < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :date, presence: true, uniqueness: { scope: :organization_id }
end
