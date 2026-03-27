class CreateKatelloErrataApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :katello_errata_applications do |t|
      t.references :host, null: false, foreign_key: { to_table: :hosts }
      t.integer :errata_ids, array: true, null: false, default: []
      t.uuid :task_id, null: true
      t.integer :user_id, null: true

      t.datetime :applied_at, null: false
      t.string :status, null: false, default: 'success'

      t.timestamps

      t.index :task_id, name: 'index_errata_apps_task_id'
      t.index :status, name: 'index_errata_apps_status'
      t.index :errata_ids, using: :gin, name: 'index_errata_apps_errata_ids'
      t.index [:host_id, :applied_at], name: 'index_errata_apps_host_date'
      t.index [:host_id, :task_id], unique: true, name: 'index_errata_apps_host_task'
    end

    add_foreign_key :katello_errata_applications, :users,
                    column: :user_id, on_delete: :nullify
  end
end
