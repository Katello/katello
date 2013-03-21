#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class ActivationKey < ActiveRecord::Base

  include Glue::ElasticSearch::ActivationKey if Katello.config.use_elasticsearch
  include Authorization::ActivationKey

  belongs_to :organization
  belongs_to :environment, :class_name => "KTEnvironment"
  belongs_to :user
  belongs_to :content_view, :inverse_of => :activation_keys

  has_many :key_pools
  has_many :pools, :class_name => "::Pool", :through => :key_pools

  has_many :key_system_groups, :dependent => :destroy
  has_many :system_groups, :through => :key_system_groups

  has_many :system_activation_keys, :dependent => :destroy
  has_many :systems, :through => :system_activation_keys

  after_find :validate_pools

  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates :name, :presence => true
  validates_uniqueness_of :name, :scope => :organization_id
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates :environment, :presence => true
  validate :environment_exists
  validate :environment_not_library
  validate :environment_key_conflict
  validates_each :usage_limit do |record, attr, value|
    if not value.nil? and (value < -1 or value == 0 or (value != -1 and value < record.usage_count))
      # we don't let users to set usage limit lower than current usage
      record.errors[attr] << _("must be higher than current usage (%s) or unlimited" % record.usage_count)
    end
  end
  validates_with Validators::ContentViewEnvironmentValidator

  def environment_exists
    if environment.nil?
      errors.add(:environment, _("ID: %s doesn't exist ") % environment_id)
    elsif environment.organization != self.organization
      errors.add(:environment, _("name: %s doesn't exist ") % environment.name)
    end
  end

  def environment_not_library
    errors.add(:base, _("Cannot create activation keys in the '%s' environment") % "Library") if environment and environment.library?
  end

  def environment_key_conflict
    conflicts = self.system_groups.select{|g| !g.environments.empty? && !g.environments.include?(self.environment)}
    names = conflicts.join(",")
    if !conflicts.empty?
      errors.add(:environment, _("The selected system groups (%s) are not compatible with the selected environment.") % names)
    end
  end

  def usage_count
    system_activation_keys.count
  end

  # sets up system when registering with this activation key - must be executed in a transaction
  def apply_to_system(system)
    if not usage_limit.nil? and usage_limit != -1 and usage_count >= usage_limit
      raise Errors::UsageLimitExhaustedException, _("Usage limit (%{limit}) exhausted for activation key '%{name}'") % {:limit => usage_limit, :name => name}
    end
    system.environment_id = self.environment_id if self.environment_id
    system.content_view_id = self.content_view_id if self.content_view_id
    system.system_activation_keys.build(:activation_key => self)
  end

  # compute number of consumptions per pool for a product to satisfy
  # the allocate requirement
  def calculate_consumption(product, pools, allocate)
    pools = pools.sort_by { |pool| [pool.start_date, pool.cp_id] }
    consumption = {}

    if product.provider.redhat_provider?
      not_allocated = pools.reduce(allocate) do |left_to_allocate, pool|
        break if left_to_allocate <= 0
        sockets = [pool.sockets, 1].max
        available = (pool.quantity == -1 ? 999_999_999 : pool.quantity) - pool.consumed
        # take the number of sockets per pool into account
        to_consume = [(left_to_allocate.to_f / sockets).ceil, available].min
        consumption[pool] = to_consume
        left_to_allocate - (to_consume * sockets)
      end

      if not_allocated.to_i > 0
        raise _("Not enough pools: %{not_allocated} sockets " +
                "out of %{allocate} not covered") %
                {:not_allocated => not_allocated, :allocate => allocate}
      end
    else
      consumption[pools.first] = 1
    end
    return consumption
  end

  # subscribe to each product according the entitlements remaining
  def subscribe_system(system)
    already_subscribed = []
    begin
      # sanity check before we start subscribing
      self.pools.each do |pool|
        raise _("Pool %s has no product associated") % pool.cp_id unless pool.product_id
        raise _("Unable to determine quantity for pool %s") % pool.cp_id unless pool.quantity
      end

      allocate = system.sockets.to_i
      Rails.logger.debug "Number of sockets for registration: #{allocate}"
      raise _("Number of sockets must be higher than 0 for system %s") % system.name if allocate <= 0

      # we sort just to make the order deterministig.
      self.pools.group_by(&:product_id).sort_by(&:first).each do |product_id, pools|
        product = Product.find_by_cp_id(product_id)
        consumption = calculate_consumption(product, pools, allocate)

        Rails.logger.debug "Autosubscribing pools: #{consumption.map { |pool, amount| "#{pool.cp_id} => #{amount}"}.join(", ")}"
        consumption.each do |pool, amount|
          Rails.logger.debug "Subscribing #{system.name} to product: #{product_id}, consuming pool #{pool.cp_id} of amount: #{amount}"
          if entitlements_array = system.subscribe(pool.cp_id, amount)
            # store for possible rollback
            entitlements_array.each do |ent|
              already_subscribed << ent['id']
            end
          end
        end
      end
    rescue => e
      Rails.logger.error "Autosubscribtion failed, rolling back: #{already_subscribed.inspect}"
      already_subscribed.each do |entitlement_id|
        begin
          Rails.logger.debug "Rolling back: #{entitlement_id}"
          entitlements_array = system.unsubscribe entitlement_id
        rescue => re
          Rails.logger.fatal "Rollback failed, skipping: #{re.message}"
        end
      end
      raise e
    end
  end

  def as_json(*args)
    ret = super(*args)
    ret[:pools] = pools.map do |pool|
      pool.as_json
    end
    ret[:usage_count] = usage_count
    ret
  end

  private

  # Fetch each of the pools from candlepin, removing any that no longer
  # exist (eg. from loss of a Virtual Guest pool)
  def validate_pools
    obsolete_pools = []
    self.pools.each do |pool|
      begin
        Resources::Candlepin::Pool.find(pool.cp_id)
      rescue RestClient::ResourceNotFound => e
        obsolete_pools << pool
      end
    end
    updated_pools = self.pools - obsolete_pools
    if self.pools != updated_pools
      self.pools = updated_pools
      self.save!
    end
  end

end
