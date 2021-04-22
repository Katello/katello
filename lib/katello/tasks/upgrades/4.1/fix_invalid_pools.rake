namespace :katello do
  namespace :upgrades do
    namespace '4.1' do
      desc "Removed orphaned pools and correct org+subscription mismatch"
      task :fix_invalid_pools => ["environment", "check_ping"] do
        logger = Logger.new(STDOUT)
        invalid_pools = Katello::Pool.all.select(&:invalid?)

        # Make sure Subscriptions are up to date for any org that has invalid pools
        org_ids = invalid_pools.map(&:organization_id).uniq.compact
        orgs = ::Organization.where(id: org_ids)
        orgs.each do |org|
          Katello::Subscription.import_all(org)
        end

        orphaned_pools = []

        invalid_pools.each do |pool|
          pool_json = Katello::Resources::Candlepin::Pool.find(pool.cp_id)

          correct_org = Organization.find_by(:label => pool_json['owner']['key'])
          unless correct_org
            orphaned_pools << pool
            logger.info("Pool id=#{pool.id} cp_id=#{pool.cp_id} will be removed because its organization does not exist")
            next
          end

          # authoritatively set the org id for this pool
          pool.organization = correct_org

          subscription = Katello::Pool.determine_subscription(
            product_id: pool_json['productId'],
            source_stack_id: pool_json['sourceStackId'],
            organization: correct_org
          )

          unless subscription
            orphaned_pools << pool
            logger.info("Pool id=#{pool.id} cp_id=#{pool.cp_id} will be removed because it has no matching subscription")
            next
          end

          pool.subscription = subscription

          # the matching subscription should have been imported above
          # with the right org assigned, import the pool and reindex associated hosts+activationkeys
          pool.import_data(true)
          logger.info("Pool id=#{pool.id} cp_id=#{pool.cp_id} has been reimported")
        rescue ::Katello::Errors::CandlepinPoolGone
          logger.info("Pool id=#{pool.id} cp_id=#{pool.cp_id} will be removed because it's not in Candlepin")
          orphaned_pools << pool
        end

        imported_count = invalid_pools.count - orphaned_pools.count
        logger.info("Corrected #{imported_count} invalid pools")

        orphaned_pools.each { |p| p.destroy }
        logger.info("Removed #{orphaned_pools.count} orphaned pools")
      end
    end
  end
end
