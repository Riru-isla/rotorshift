class Schedule < ApplicationRecord
  belongs_to :organization
  belongs_to :published_by, class_name: "User", optional: true

  has_many :schedule_entries, dependent: :destroy

  enum :status, { draft: 0, published: 1, archived: 2 }

  validates :year, presence: true, numericality: { greater_than: 2000 }
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, uniqueness: { scope: [:organization_id, :month] }
end
