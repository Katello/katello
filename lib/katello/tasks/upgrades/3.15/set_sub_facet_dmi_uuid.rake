namespace :katello do
  namespace :upgrades do
    namespace '3.15' do
      desc "Set the DMI UUID on Host::SubscriptionFacet from facts"
      task :set_sub_facet_dmi_uuid, [:input_file] => ["environment"] do
        User.current = User.anonymous_api_admin
        dmi_uuid_fact_name = Katello::RhsmFactName.find_by_name('dmi::system::uuid') || -1

        fact_values = ::FactValue.where(fact_name: dmi_uuid_fact_name).where.not(value: nil)
        fact_values.each do |fv|
          fv.host.subscription_facet&.update_attributes(dmi_uuid: fv.value)
        end
      end
    end
  end
end
