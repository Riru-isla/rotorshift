class CreateUnavailableDays < ActiveRecord::Migration[8.1]
  def change
    create_table :unavailable_days do |t|
      t.references :pilot_profile, null: false, foreign_key: true
      t.date :date, null: false
      t.text :reason

      t.timestamps
    end

    add_index :unavailable_days, [:pilot_profile_id, :date], unique: true
  end
end
