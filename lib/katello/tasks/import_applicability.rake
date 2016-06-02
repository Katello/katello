namespace :katello do
  task :import_applicability => ["environment"] do
    Katello::Host::ContentFacet.find_each do |facet|
      begin
        facet.import_applicability
      rescue StandardError => exception
        puts _('Error importing applicability for %{name} - %{id}: %{message}') %
            {:name => facet.host.name, :id => facet.host.id, :message => exception.message}
      end
    end
  end
end
