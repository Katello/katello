module Actions
  module Candlepin
    module Product
      class DeletePools < Candlepin::Abstract
        input_format do
          param :organization_label
          param :cp_id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.pools(input[:organization_label], input[:cp_id]).each do |pool|
            ::Katello::Pool.where(:cp_id => pool['id']).each(&:destroy)
            ::Katello::Resources::Candlepin::Pool.destroy(pool['id'])
          end
        end
      end
    end
  end
end
