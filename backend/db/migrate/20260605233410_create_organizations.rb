class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :timezone, null: false, default: "UTC"
      t.string :country
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :organizations, :code, unique: true
  end
end
