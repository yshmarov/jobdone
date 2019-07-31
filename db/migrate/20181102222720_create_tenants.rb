class CreateTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants do |t|
      t.references :tenant, foreign_key: true
      t.string :name, :limit => 40, null: false
      t.string :plan, :limit => 40, null: false
      t.string :default_currency, :limit => 3, null: false, default: "usd"
      t.string :locale, :limit => 2, null: false, default: 'en'
      t.string :industry, :limit => 144, default: "other", null: false
      t.string :logo, :limit => 500
      t.string :website, :limit => 500
      #t.string :default_time_zone, null: false
      #t.string :default_working_hours

      t.timestamps
    end
    add_index :tenants, :name
    add_index :tenants, :plan
    add_index :tenants, :default_currency
    add_index :tenants, :locale
  end
end