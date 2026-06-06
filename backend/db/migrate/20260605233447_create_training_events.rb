class CreateTrainingEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :training_events do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :pilot_profile, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :mandatory, null: false, default: true
      t.text :notes

      t.timestamps
    end

    add_index :training_events, [:pilot_profile_id, :starts_at]
  end
end
