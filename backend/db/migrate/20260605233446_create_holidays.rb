class CreateHolidays < ActiveRecord::Migration[8.1]
  def change
    create_table :holidays do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.date :date, null: false
      t.boolean :recurring, null: false, default: false

      t.timestamps
    end

    add_index :holidays, [:organization_id, :date], unique: true
  end
end
