class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.belongs_to :tenant, index: true, foreign_key: true
      t.belongs_to :event, foreign_key: true
      t.belongs_to :service, foreign_key: true
      t.belongs_to :member, foreign_key: true

      t.integer :service_duration, default: 0, null: false
      t.integer :service_member_percent, default: 0, null: false
      t.integer :service_client_price, default: 0, null: false

      t.integer :client_price, default: 0, null: false
      t.integer :client_due_price, default: 0, null: false
      t.integer :member_price, default: 0, null: false
      t.integer :member_due_price, default: 0, null: false

      t.integer :add_amount, default: 0, null: false
      t.integer :production_cost, default: 0, null: false

      t.timestamps
    end
  end
end
