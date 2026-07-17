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

ActiveRecord::Schema[7.2].define(version: 2025_06_15_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "phone"], name: "index_customers_on_organization_id_and_phone"
    t.index ["organization_id"], name: "index_customers_on_organization_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id"
    t.string "name", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.integer "line_total_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "customer_id"
    t.bigint "user_id"
    t.string "order_number", null: false
    t.string "source", default: "order_pad", null: false
    t.string "status", default: "pending", null: false
    t.string "payment_method"
    t.string "payment_status", default: "unpaid", null: false
    t.string "mpesa_reference"
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["organization_id", "created_at"], name: "index_orders_on_organization_id_and_created_at"
    t.index ["organization_id", "order_number"], name: "index_orders_on_organization_id_and_order_number", unique: true
    t.index ["organization_id", "status"], name: "index_orders_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "currency", default: "KES", null: false
    t.jsonb "enabled_modules", default: ["order_pad", "pos"], null: false
    t.string "plan", default: "starter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "sku"
    t.integer "price_cents", default: 0, null: false
    t.integer "stock_quantity", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "sku"], name: "index_products_on_organization_id_and_sku", unique: true, where: "(sku IS NOT NULL)"
    t.index ["organization_id"], name: "index_products_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "owner", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "customers", "organizations"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "organizations"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "organizations"
  add_foreign_key "users", "organizations"
end
