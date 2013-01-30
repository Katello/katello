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
  belongs_to :system_template

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
  validate :system_template_exists
  validate :environment_not_library
  validate :environment_key_conflict
  validates_each :usage_limit do |record, attr, value|
    if not value.nil? and (value < -1 or value == 0 or (value != -1 and value < record.usage_count))
      # we don't let users to set usage limit lower than current usage
      record.errors[attr] << _("must be higher than current usage (%s) or unlimited" % record.usage_count)
    end
  end

  def system_template_exists
    if system_template && system_template.environment != self.environment
      errors.add(:system_template, _("name: %s doesn't exist ") % system_template.name)
    end
  end

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
    system.system_template_id = self.system_template_id if self.system_template_id
    system.system_activation_keys.build(:activation_key => self)
  end

  # calculate entitlement consumption for given amount and pool quantity left, example use:
  #   calculate_consumption(4, [10, 10]) -> [4, 0]
  #   calculate_consumption(4, [3, 2]) -> [3, 1]
  #   calculate_consumption(4, [1, 2, 1]) -> [1, 2, 1]
  #   calculate_consumption(4, [1, 1]) -> exception "Not enough entitlements"
  #   calculate_consumption(4, []) -> exception "Not enough entitlements"
  def calculate_consumption(amount = 1, entitlements = [])
    a = amount
    result = entitlements.collect do |x|
      if a > 0
        min = [a,x].min
        a = a - min
        min
      else
        0
      end
    end
    total = result.inject{|sum,x| sum + x }
    raise _("Not enough subscriptions in pools (%{size}), required: %{required}, available: %{available}") % {:size => entitlements.size, :required => amount, :available => total} if amount != total
    result
  end

  # subscribe to each product according the entitlements remaining
  def subscribe_system(system)
    already_subscribed = []
    begin
      # collect products involved in this activation key as a hash in the following format:
      # {"productId" => { "poolId_1" => [start_date, entitlements_left], "poolId_2" => ... } }
      products = {}
      self.pools.each do |pool|
        raise _("Pool %s has no product associated") % pool.cp_id unless pool.product_id
        products[pool.product_id] = {} unless products.key? pool.product_id
        quantity = pool.quantity == -1 ? 999_999_999 : pool.quantity
        raise _("Unable to determine quantity for pool %s") % pool.cp_id if quantity.nil?
        left = quantity - pool.consumed
        raise _("Number of attached subscriptions exceeded quantity for %s") % pool.cp_id if left < 0
        products[pool.product_id][pool.cp_id] = [pool.start_date, left]
      end

      # for each product consumer "allocate" amount of entitlements
      allocate = system.sockets.to_i
      Rails.logger.debug "Number of sockets for registration: #{allocate}"
      raise _("Number of sockets must be higher than 0 for system %s") % system.name if allocate.nil? or allocate <= 0
      #puts products.inspect
      products.each do |productId, pools|
        product = Product.find_by_cp_id(productId)
        # create two arrays - pool ids and remaining entitlements
        # subscription order is with most recent start or with the least pool number available
        pools_a = pools.to_a.sort { |a,b| (a[1][0] <=> b[1][0]).nonzero? || (a[0] <=> b[0]) }
        pools_ids = []
        pools_left = []
        pools_a.each { |p| pools_ids << p[0]; pools_left << p[1][1] }

        if product.provider.redhat_provider?
          # calculate consumption array (throws an error when there are not enough entitlements)
          to_consume = calculate_consumption(allocate, pools_left)
        else
          to_consume = 1
        end
        i = 0
        Rails.logger.debug "Autosubscribing pools: #{pools_ids.inspect} with amounts: #{to_consume.inspect}"
        pools_ids.each do |poolId|
          amount = to_consume[i]
          Rails.logger.debug "Subscribing #{system.name} to product: #{productId}, amount: #{amount}"
          if amount > 0
            entitlements_array = system.subscribe(poolId, amount)
            # store for possible rollback
            entitlements_array.each do |ent|
              already_subscribed << ent['id']
            end unless entitlements_array.nil?
          end
          i = i + 1
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

  def extended_json
    to_ret = {:environment=>self.environment.name, :name_sort=>name.downcase}
    to_ret[:template] = self.system_template.name if self.system_template
    to_ret
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
