class AddAnonymousProvidersToOrgs < ActiveRecord::Migration[4.2]
  def up
    Organization.all.each do |org|
      if org.anonymous_provider.nil?
        Katello::Provider.create!(:name => Katello::Provider::ANONYMOUS, :provider_type => Katello::Provider::ANONYMOUS, :organization => org)
      end
    end
  end
end
