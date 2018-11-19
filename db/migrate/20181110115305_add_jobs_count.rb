class AddJobsCount < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :jobs_count, :integer, default: 0, null: false
    add_column :employees, :jobs_count, :integer, default: 0, null: false
    add_column :locations, :jobs_count, :integer, default: 0, null: false
    add_column :services, :jobs_count, :integer, default: 0, null: false
  end
end