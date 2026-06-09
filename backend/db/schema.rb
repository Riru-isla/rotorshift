# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_08_101239) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "holidays", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.boolean "recurring", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "date"], name: "index_holidays_on_organization_id_and_date", unique: true
    t.index ["organization_id"], name: "index_holidays_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_organizations_on_code", unique: true
  end

  create_table "pilot_profiles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "license_number"
    t.date "rotation_start_date", null: false
    t.bigint "shift_pattern_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["license_number"], name: "index_pilot_profiles_on_license_number", unique: true, where: "(license_number IS NOT NULL)"
    t.index ["shift_pattern_id"], name: "index_pilot_profiles_on_shift_pattern_id"
    t.index ["user_id"], name: "index_pilot_profiles_on_user_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "schedule_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "entry_type", default: 0, null: false
    t.text "notes"
    t.bigint "pilot_profile_id", null: false
    t.bigint "schedule_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pilot_profile_id"], name: "index_schedule_entries_on_pilot_profile_id"
    t.index ["schedule_id", "date"], name: "index_schedule_entries_on_schedule_id_and_date"
    t.index ["schedule_id", "pilot_profile_id", "date"], name: "idx_schedule_entries_unique", unique: true
    t.index ["schedule_id"], name: "index_schedule_entries_on_schedule_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "month", null: false
    t.string "name"
    t.bigint "organization_id", null: false
    t.datetime "published_at"
    t.bigint "published_by_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["organization_id", "year", "month"], name: "index_schedules_unique_published_per_month", unique: true, where: "(status = 1)"
    t.index ["organization_id"], name: "index_schedules_on_organization_id"
    t.index ["published_by_id"], name: "index_schedules_on_published_by_id"
  end

  create_table "shift_patterns", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "days_off", null: false
    t.integer "days_on", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_shift_patterns_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_shift_patterns_on_organization_id"
  end

  create_table "staffing_requirements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.integer "minimum_pilots", null: false
    t.text "notes"
    t.bigint "organization_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "start_date", "end_date"], name: "idx_staffing_requirements_on_org_and_dates"
    t.index ["organization_id"], name: "index_staffing_requirements_on_organization_id"
  end

  create_table "training_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.boolean "mandatory", default: true, null: false
    t.text "notes"
    t.bigint "organization_id", null: false
    t.bigint "pilot_profile_id", null: false
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_training_events_on_organization_id"
    t.index ["pilot_profile_id", "starts_at"], name: "index_training_events_on_pilot_profile_id_and_starts_at"
    t.index ["pilot_profile_id"], name: "index_training_events_on_pilot_profile_id"
  end

  create_table "unavailable_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "pilot_profile_id", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.index ["pilot_profile_id", "date"], name: "index_unavailable_days_on_pilot_profile_id_and_date", unique: true
    t.index ["pilot_profile_id"], name: "index_unavailable_days_on_pilot_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "jti", null: false
    t.string "last_name", null: false
    t.bigint "organization_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vacation_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.bigint "pilot_profile_id", null: false
    t.text "reason"
    t.text "review_notes"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["pilot_profile_id", "status"], name: "index_vacation_requests_on_pilot_profile_id_and_status"
    t.index ["pilot_profile_id"], name: "index_vacation_requests_on_pilot_profile_id"
    t.index ["reviewed_by_id"], name: "index_vacation_requests_on_reviewed_by_id"
  end

  add_foreign_key "holidays", "organizations"
  add_foreign_key "pilot_profiles", "shift_patterns"
  add_foreign_key "pilot_profiles", "users"
  add_foreign_key "schedule_entries", "pilot_profiles"
  add_foreign_key "schedule_entries", "schedules"
  add_foreign_key "schedules", "organizations"
  add_foreign_key "schedules", "users", column: "published_by_id"
  add_foreign_key "shift_patterns", "organizations"
  add_foreign_key "staffing_requirements", "organizations"
  add_foreign_key "training_events", "organizations"
  add_foreign_key "training_events", "pilot_profiles"
  add_foreign_key "unavailable_days", "pilot_profiles"
  add_foreign_key "users", "organizations"
  add_foreign_key "vacation_requests", "pilot_profiles"
  add_foreign_key "vacation_requests", "users", column: "reviewed_by_id"
end
