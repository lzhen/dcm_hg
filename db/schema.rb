# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111121203640) do

  create_table "course_proficiencies", :force => true do |t|
    t.integer  "course_id"
    t.integer  "proficiency_id"
    t.string   "proficiency_direction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "slot"
  end

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.string   "prefix"
    t.integer  "number"
    t.text     "description"
    t.integer  "credit_hours"
    t.boolean  "is_existing"
    t.date     "anticipated_start_date"
    t.string   "classification"
    t.string   "frequency"
    t.string   "facility_needs"
    t.integer  "total_seats"
    t.integer  "reserved_seats"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "other_special_needs"
    t.text     "hs_incoming_proficiencies"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "happens_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "photo_updated_at"
  end

  create_table "external_course_proficiencies", :force => true do |t|
    t.integer  "external_course_id"
    t.integer  "proficiency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_courses", :force => true do |t|
    t.string   "title"
    t.string   "prefix"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_instances", :force => true do |t|
    t.integer  "external_course_id"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instances", :force => true do |t|
    t.integer  "course_id"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", :force => true do |t|
    t.string   "subject"
    t.text     "details"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "level"
    t.string   "remote_ip"
    t.string   "referer"
    t.string   "request"
    t.string   "method"
    t.string   "user_agent"
    t.string   "message"
    t.string   "controller", :limit => 100
    t.string   "action",     :limit => 100
    t.datetime "created_at"
  end

  create_table "path_external_instances", :force => true do |t|
    t.integer  "path_id"
    t.integer  "external_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "path_instances", :force => true do |t|
    t.integer  "path_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paths", :force => true do |t|
    t.integer  "student_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proficiencies", :force => true do |t|
    t.string   "name"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "course_id"
    t.integer  "user_id"
    t.string   "recommendation_type"
    t.text     "recommendation_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "student_id"
    t.integer  "course_id"
    t.text     "review_text"
    t.boolean  "recommend",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
  end

  create_table "rights", :force => true do |t|
    t.integer  "user_id"
    t.string   "prefix"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semesters", :force => true do |t|
    t.string   "name"
    t.string   "year"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_courses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "degree"
    t.string   "user_type"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                     :limit => 40
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "current_path"
    t.boolean  "is_event_editor",                          :default => false
  end

end
