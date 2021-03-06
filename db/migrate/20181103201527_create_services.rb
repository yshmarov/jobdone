class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services do |t|
      t.belongs_to :tenant, index: true, foreign_key: true
      t.belongs_to :service_category, foreign_key: true
      t.string :name, limit: 144, null: false
      t.string :description
      t.integer :duration, null: false

      t.integer :client_price, default: 0, null: false
      t.integer :member_percent, default: 0, null: false
      t.integer :member_price, default: 0, null: false

      # t.integer :repeat_reminder, default: 0, null: false
      t.integer :jobs_count, :integer, default: 0, null: false

      t.boolean :online_booking, default: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
