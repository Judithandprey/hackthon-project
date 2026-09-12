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

ActiveRecord::Schema[7.2].define(version: 2026_09_11_000001) do
  create_table "hack_applications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "organization", default: "", null: false
    t.string "skills", default: "", null: false
    t.text "motivation", default: "", null: false
    t.text "experience", default: "", null: false
    t.string "availability", default: "", null: false
    t.string "portfolio_url", default: "", null: false
    t.string "status", default: "draft", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_hack_applications_on_status"
    t.index ["user_id"], name: "index_hack_applications_on_user_id", unique: true
    t.check_constraint "status IN ('draft','submitted','under_review','accepted','waitlisted','declined')", name: "valid_application_status"
  end

  create_table "login_attempts", force: :cascade do |t|
    t.string "email_digest", null: false
    t.integer "attempts", default: 0, null: false
    t.datetime "reset_at", null: false
    t.index ["email_digest"], name: "index_login_attempts_on_email_digest", unique: true
  end

  create_table "login_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_login_sessions_on_expires_at"
    t.index ["token_digest"], name: "index_login_sessions_on_token_digest", unique: true
    t.index ["user_id"], name: "index_login_sessions_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "hack_application_id", null: false
    t.integer "reviewer_id", null: false
    t.integer "readiness", null: false
    t.integer "impact", null: false
    t.integer "collaboration", null: false
    t.text "notes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hack_application_id"], name: "index_reviews_on_hack_application_id", unique: true
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.check_constraint "collaboration BETWEEN 1 AND 5", name: "valid_collaboration"
    t.check_constraint "impact BETWEEN 1 AND 5", name: "valid_impact"
    t.check_constraint "readiness BETWEEN 1 AND 5", name: "valid_readiness"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "hacker", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role IN ('hacker','mentor','organizer')", name: "valid_user_role"
  end

  add_foreign_key "hack_applications", "users"
  add_foreign_key "login_sessions", "users"
  add_foreign_key "reviews", "hack_applications"
  add_foreign_key "reviews", "users", column: "reviewer_id"
end
