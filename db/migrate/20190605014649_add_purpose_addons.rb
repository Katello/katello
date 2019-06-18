class AddPurposeAddons < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_purpose_addons do |t|
      t.string :name, null: false
    end

    create_table :katello_subscription_facet_purpose_addons do |t|
      t.references :purpose_addon, index: { name: :katello_sub_facet_purpose_addons_paid }
      t.references :subscription_facet, index: { name: :katello_sub_facet_purpose_addons_sfid }
    end

    add_foreign_key :katello_subscription_facet_purpose_addons, :katello_subscription_facets, column: :subscription_facet_id, name: :katello_sub_facet_purpose_addon_facet_id
    add_foreign_key :katello_subscription_facet_purpose_addons, :katello_purpose_addons, column: :purpose_addon_id, name: :katello_sub_facet_purpose_addon_purpose_addon_id

    Katello::Host::SubscriptionFacet.pluck(:id, :purpose_addons).each do |facet|
      yaml_string = facet[1]
      next if yaml_string.nil?

      parsed = YAML.parse(yaml_string)
      addon_names = parsed.root.children.map(&:value)
      addon_names.each do |addon|
        purpose_addon = Katello::PurposeAddon.find_or_create_by(name: addon)
        Katello::SubscriptionFacetPurposeAddon.create(purpose_addon_id: purpose_addon.id, subscription_facet_id: facet[0])
      end
    end

    remove_column :katello_subscription_facets, :purpose_addons, :text
  end
end
