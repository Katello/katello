namespace :katello do
  namespace :upgrades do
    namespace '3.6' do
      desc "Import product content from Candlepin to improve API performance and enhance searching"
      task :import_product_content => %w(environment check_ping) do
        User.current = User.anonymous_admin

        Katello::Content.import_all
      end
    end
  end
end
