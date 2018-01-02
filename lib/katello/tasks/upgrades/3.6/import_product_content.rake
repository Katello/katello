namespace :katello do
  namespace :upgrades do
    namespace '3.6' do
      desc "Import product content from Candlepin to improve API performance and enhance searching"
      task :import_product_content => %w(environment check_ping) do
        User.current = User.anonymous_admin

        Organization.all.each do |org|
          org.products.each do |product|
            begin
              product_json = Katello::Resources::Candlepin::Product.get(org.label,
                                                                    product.cp_id,
                                                                    %w(productContent)).first
              product_content_attrs = product_json['productContent']
              Katello::Glue::Candlepin::Product.import_product_content(product, product_content_attrs)
            rescue RestClient::NotFound
              puts "Product with ID #{product.cp_id} not found in Candlepin. Skipping content import for it."
            end
          end
        end
      end
    end
  end
end
