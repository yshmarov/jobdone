class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.belongs_to :client, foreign_key: true
      t.datetime :start
      t.integer :status, default: 0, null: false
      t.belongs_to :service, foreign_key: true
      t.belongs_to :location, foreign_key: true
      t.belongs_to :employee, foreign_key: true
      t.string :service_name, default: 0, null: false
      t.string :service_description, default: 0, null: false
      t.integer :service_duration, default: 0, null: false
      t.integer :client_price, default: 0, null: false
      t.integer :employee_price, default: 0, null: false

      t.timestamps
    end
  end
end
