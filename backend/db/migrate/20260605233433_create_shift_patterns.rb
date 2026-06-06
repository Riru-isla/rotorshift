class CreateShiftPatterns < ActiveRecord::Migration[8.1]
  def change
    create_table :shift_patterns do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :days_on, null: false
      t.integer :days_off, null: false
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :shift_patterns, [:organization_id, :name], unique: true
  end
end
