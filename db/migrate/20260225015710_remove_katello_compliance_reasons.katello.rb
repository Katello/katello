class RemoveKatelloComplianceReasons < ActiveRecord::Migration[7.0]
  def up
    drop_table :katello_compliance_reasons
    remove_column :katello_pools, :consumed
    remove_column :katello_pools, :virtual
  end

  def down
    create_table :katello_compliance_reasons do |t|
      t.string :reason
      t.references :subscription_facet
    end

    add_foreign_key "katello_compliance_reasons", "katello_subscription_facets",
                        :name => "katello_compliance_reasons_facet_id", :column => "subscription_facet_id"

    add_column :katello_pools, :consumed, :integer
    add_column :katello_pools, :virtual, :boolean
  end
end
