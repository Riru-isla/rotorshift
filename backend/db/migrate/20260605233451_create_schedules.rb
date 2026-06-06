class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :status, null: false, default: 0
      t.datetime :published_at
      t.references :published_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :schedules, [:organization_id, :year, :month], unique: true
  end
end
