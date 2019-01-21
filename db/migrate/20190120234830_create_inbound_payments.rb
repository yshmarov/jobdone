class CreateInboundPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :inbound_payments do |t|
      t.references :tenant, foreign_key: true
      t.references :event, foreign_key: true
      t.references :client, foreign_key: true
      t.integer :amount, default: 0, null: false
      t.string :payment_method, default: 'cash', null: false

      t.timestamps
    end
  end
end
