class CreateScheduleEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_entries do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :pilot_profile, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :entry_type, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :schedule_entries, [:schedule_id, :pilot_profile_id, :date],
              unique: true, name: "idx_schedule_entries_unique"
    add_index :schedule_entries, [:schedule_id, :date]
  end
end
