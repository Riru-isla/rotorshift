class CreateVacationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :vacation_requests do |t|
      t.references :pilot_profile, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :status, null: false, default: 0
      t.text :reason
      t.references :reviewed_by, null: true, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.text :review_notes

      t.timestamps
    end

    add_index :vacation_requests, [:pilot_profile_id, :status]
  end
end
