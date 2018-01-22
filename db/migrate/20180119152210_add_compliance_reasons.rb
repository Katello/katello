class AddComplianceReasons < ActiveRecord::Migration[5.1]
  def change
    create_table :katello_compliance_reasons do |t|
      t.string :reason
      t.references :subscription_facet
    end

    add_foreign_key "katello_compliance_reasons", "katello_subscription_facets",
                        :name => "katello_compliance_reasons_facet_id", :column => "subscription_facet_id"
  end
end
