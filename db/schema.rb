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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180718161302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dimensions_dates", primary_key: "date", id: :date, force: :cascade do |t|
    t.string "date_name", null: false
    t.string "date_name_abbreviated", null: false
    t.integer "year", null: false
    t.integer "quarter", null: false
    t.integer "month", null: false
    t.string "month_name", null: false
    t.string "month_name_abbreviated", null: false
    t.integer "week", null: false
    t.integer "day_of_year", null: false
    t.integer "day_of_quarter", null: false
    t.integer "day_of_month", null: false
    t.integer "day_of_week", null: false
    t.string "day_name", null: false
    t.string "day_name_abbreviated", null: false
    t.string "weekday_weekend", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_name"], name: "index_dimensions_dates_on_date_name"
  end

  create_table "dimensions_items", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "title"
    t.string "base_path", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "latest"
    t.json "raw_json"
    t.string "document_type"
    t.string "content_purpose_document_supertype"
    t.datetime "first_published_at"
    t.datetime "public_updated_at"
    t.string "primary_organisation_title"
    t.string "primary_organisation_content_id"
    t.boolean "primary_organisation_withdrawn"
    t.string "locale"
    t.bigint "publishing_api_payload_version", null: false
    t.string "content_purpose_supergroup"
    t.string "content_purpose_subgroup"
    t.string "schema_name", null: false
    t.text "document_text"
    t.index ["base_path", "latest"], name: "index_dimensions_items_on_base_path_and_latest", unique: true, where: "(latest = true)"
    t.index ["base_path"], name: "index_dimensions_items_on_base_path"
    t.index ["content_id", "latest"], name: "index_dimensions_items_on_content_id_and_latest"
    t.index ["primary_organisation_content_id"], name: "index_dimensions_items_primary_organisation_content_id"
  end

  create_table "events_feedexes", force: :cascade do |t|
    t.date "date"
    t.string "page_path"
    t.integer "feedex_comments"
    t.index ["page_path", "date"], name: "index_events_feedexes_on_page_path_and_date"
  end

  create_table "events_gas", force: :cascade do |t|
    t.date "date"
    t.string "page_path"
    t.integer "pageviews", default: 0
    t.integer "unique_pageviews", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_this_useful_yes", default: 0
    t.integer "is_this_useful_no", default: 0
    t.integer "process_name", null: false
    t.integer "number_of_internal_searches", default: 0
    t.integer "exits", default: 0
    t.integer "entrances", default: 0
    t.integer "bounce_rate", default: 0
    t.integer "avg_time_on_page", default: 0
    t.index ["page_path", "date"], name: "index_events_gas_on_page_path_and_date"
    t.index ["process_name", "date", "page_path"], name: "index_events_gas_on_process_name_and_date_and_page_path", unique: true
  end

  create_table "facts_editions", force: :cascade do |t|
    t.date "dimensions_date_id", null: false
    t.bigint "dimensions_item_id", null: false
    t.integer "number_of_pdfs"
    t.integer "number_of_word_files"
    t.integer "readability_score"
    t.integer "contractions_count"
    t.integer "equality_count"
    t.integer "indefinite_article_count"
    t.integer "passive_count"
    t.integer "profanities_count"
    t.integer "redundant_acronyms_count"
    t.integer "repeated_words_count"
    t.integer "simplify_count"
    t.integer "spell_count"
    t.integer "string_length"
    t.integer "sentence_count"
    t.integer "word_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dimensions_item_id", "dimensions_date_id"], name: "editions_item_id_date_id", unique: true
  end

  create_table "facts_metrics", force: :cascade do |t|
    t.date "dimensions_date_id", null: false
    t.bigint "dimensions_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pageviews", default: 0
    t.integer "unique_pageviews", default: 0
    t.integer "feedex_comments", default: 0
    t.integer "is_this_useful_yes", default: 0
    t.integer "is_this_useful_no", default: 0
    t.integer "number_of_internal_searches", default: 0
    t.integer "exits", default: 0
    t.integer "entrances", default: 0
    t.integer "bounce_rate", default: 0
    t.integer "avg_time_on_page", default: 0
    t.index ["dimensions_date_id", "dimensions_item_id"], name: "metrics_item_id_date_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "facts_editions", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_editions", "dimensions_items"
  add_foreign_key "facts_metrics", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_metrics", "dimensions_items"
end
