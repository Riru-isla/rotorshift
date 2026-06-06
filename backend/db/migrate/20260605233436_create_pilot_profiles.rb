class CreatePilotProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :pilot_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :shift_pattern, null: false, foreign_key: true
      t.string :license_number
      t.date :rotation_start_date, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :pilot_profiles, :license_number, unique: true, where: "license_number IS NOT NULL"
  end
end
