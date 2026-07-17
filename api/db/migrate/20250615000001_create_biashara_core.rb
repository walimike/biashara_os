class CreateBiasharaCore < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :currency, null: false, default: "KES"
      t.jsonb :enabled_modules, null: false, default: [ "order_pad", "pos" ]
      t.string :plan, null: false, default: "starter"

      t.timestamps
    end
    add_index :organizations, :slug, unique: true

    create_table :users do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "owner"

      t.timestamps
    end
    add_index :users, [ :organization_id, :email ], unique: true
    add_index :users, :email

    create_table :products do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku
      t.integer :price_cents, null: false, default: 0
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :products, [ :organization_id, :sku ], unique: true, where: "sku IS NOT NULL"

    create_table :customers do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.text :notes

      t.timestamps
    end
    add_index :customers, [ :organization_id, :phone ]

    create_table :orders do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.references :user, foreign_key: true
      t.string :order_number, null: false
      t.string :source, null: false, default: "order_pad"
      t.string :status, null: false, default: "pending"
      t.string :payment_method
      t.string :payment_status, null: false, default: "unpaid"
      t.string :mpesa_reference
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.text :notes

      t.timestamps
    end
    add_index :orders, [ :organization_id, :order_number ], unique: true
    add_index :orders, [ :organization_id, :created_at ]
    add_index :orders, [ :organization_id, :status ]

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.string :name, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false, default: 0
      t.integer :line_total_cents, null: false, default: 0

      t.timestamps
    end
  end
end
