class CreateKatelloErrataApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :katello_errata_applications do |t|
      t.references :host, null: false, foreign_key: { to_table: :hosts }
      t.references :erratum, null: false, foreign_key: { to_table: :katello_errata }
      t.string :task_id, null: true, limit: 255
      t.integer :user_id, null: true

      t.datetime :applied_at, null: false
      t.string :status, null: false, default: 'success'
      t.string :method, null: false, default: 'remote_execution'

      t.timestamps

      t.index :task_id, name: 'index_errata_apps_task_id'
      t.index :status, name: 'index_errata_apps_status'
      t.index [:host_id, :erratum_id, :applied_at], unique: true, name: 'index_errata_apps_host_erratum_date'
      t.index [:host_id, :applied_at], name: 'index_errata_apps_host_date'
      t.index [:erratum_id, :applied_at], name: 'index_errata_apps_erratum_date'
    end

    add_foreign_key :katello_errata_applications, :users,
                    column: :user_id, on_delete: :nullify
  end
end
