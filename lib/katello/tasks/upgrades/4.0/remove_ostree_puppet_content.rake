namespace :katello do
  namespace :upgrades do
    namespace '4.0' do
      desc "Removes ostree & puppet content from candlepin and katello."
      task :remove_ostree_puppet_content => ["environment", "check_ping"] do
        contents = Katello::Content.where(content_type: ['ostree', 'puppet'])
        contents.each do |content|
          unless content.products.any?(&:redhat?)
            Katello::Resources::Candlepin::Content.destroy(content.organization.label, content.cp_content_id)
            content.destroy
          end
        rescue RestClient::NotFound
          #skip content not found
        end
      end
    end
  end
end
