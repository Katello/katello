module Katello
  class PoolProduct < Katello::Model
    belongs_to :product, :inverse_of => :pool_products, :class_name => 'Katello::Product'
    belongs_to :pool, :inverse_of => :pool_products, :class_name => 'Katello::Pool'
  end
end
