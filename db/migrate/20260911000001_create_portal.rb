class CreatePortal < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "hacker"
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_check_constraint :users, "role IN ('hacker','mentor','organizer')", name: "valid_user_role"

    create_table :login_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :login_sessions, :token_digest, unique: true
    add_index :login_sessions, :expires_at

    create_table :login_attempts do |t|
      t.string :email_digest, null: false
      t.integer :attempts, null: false, default: 0
      t.datetime :reset_at, null: false
    end
    add_index :login_attempts, :email_digest, unique: true

    create_table :hack_applications do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :organization, null: false, default: ""
      t.string :skills, null: false, default: ""
      t.text :motivation, null: false, default: ""
      t.text :experience, null: false, default: ""
      t.string :availability, null: false, default: ""
      t.string :portfolio_url, null: false, default: ""
      t.string :status, null: false, default: "draft"
      t.integer :lock_version, null: false, default: 0
      t.datetime :submitted_at
      t.timestamps
    end
    add_index :hack_applications, :status
    add_check_constraint :hack_applications, "status IN ('draft','submitted','under_review','accepted','waitlisted','declined')", name: "valid_application_status"

    create_table :reviews do |t|
      t.references :hack_application, null: false, foreign_key: true, index: { unique: true }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.integer :readiness, null: false
      t.integer :impact, null: false
      t.integer :collaboration, null: false
      t.text :notes, null: false, default: ""
      t.timestamps
    end
    %w[readiness impact collaboration].each do |criterion|
      add_check_constraint :reviews, "#{criterion} BETWEEN 1 AND 5", name: "valid_#{criterion}"
    end
  end
end
