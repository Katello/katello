namespace :katello do
  desc "Fix missing repository content in candlepin"
  task :fix_candlepin_content => ["environment", "check_ping"] do
    logger = Logger.new(STDOUT)
    User.current = User.anonymous_api_admin

    Katello::Resources::Candlepin::Owner.all.each do |owner|
      logger.debug("Checking Products in Organization #{owner['name']}(#{owner['key']})")
      org = Organization.find_by(label: owner['key'])

      # find_missing associations
      Katello::Resources::Candlepin::Product.all(owner['key']).each do |cp_product|
        katello_product = Katello::Product.find_by_cp_id(cp_product['id'], org)
        logger.debug("Checking '#{cp_product['name']}'")
        content_count_in_cp = cp_product['productContent'].length
        content_count_in_katello = katello_product.contents.count
        logger.debug("Product has #{content_count_in_cp} content entries in Candlepin and #{content_count_in_katello} in Katello")
        if content_count_in_cp != content_count_in_katello
          logger.info("Product '#{cp_product['name']}' has #{content_count_in_cp} content entries in Candlepin but #{content_count_in_katello} in Katello")

          existing_content_ids = cp_product['productContent'].
            map { |e| e['content']['id'] }.uniq
          missing_content = katello_product.contents.where.not(cp_content_id: existing_content_ids)

          missing_content.each do |katello_content|
            logger.warn("Product #{katello_product.name.inspect} is missing Content #{katello_content.name.inspect}")
            Katello::Resources::Candlepin::Product.remove_content(
              owner['key'],
              cp_product['id'],
              katello_content.cp_content_id
            )
            Katello::Resources::Candlepin::Product.add_content(
              owner['key'],
              cp_product['id'],
              katello_content.cp_content_id,
              true  # enabled=false only seems to occur for RHEL content
            )
          end
        end
      end
    end
  end
end
