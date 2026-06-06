class CreateStaffingRequirements < ActiveRecord::Migration[8.1]
  def change
    create_table :staffing_requirements do |t|
      t.references :organization, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :minimum_pilots, null: false
      t.text :notes

      t.timestamps
    end

    add_index :staffing_requirements, [:organization_id, :start_date, :end_date],
              name: "idx_staffing_requirements_on_org_and_dates"
  end
end
