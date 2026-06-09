class AddNameAndDescriptionToSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :schedules, :name, :string
    add_column :schedules, :description, :text

    remove_index :schedules, [:organization_id, :year, :month]
    add_index :schedules, [:organization_id, :year, :month],
              unique: true,
              where: "status = 1",
              name: "index_schedules_unique_published_per_month"
  end
end
