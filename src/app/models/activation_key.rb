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
  include Authorization
  include IndexedModel

  index_options :extended_json=>:extended_json, :display_attrs=>[:name, :description, :environment, :template]

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end


  belongs_to :organization
  belongs_to :environment, :class_name => "KTEnvironment"
  belongs_to :user
  belongs_to :system_template

  has_many :key_pools
  has_many :pools, :class_name => "KTPool", :through => :key_pools

  scope :readable, lambda {|org| ActivationKey.readable?(org) ? where(:organization_id=>org.id) : where("0 = 1")}

  after_find :validate_pools

  validates :name, :presence => true, :katello_name_format => true, :length => { :maximum => 255 }
  validates_uniqueness_of :name, :scope => :organization_id
  validates :description, :katello_description_format => true
  validates :environment, :presence => true
  validate :environment_exists
  validate :system_template_exists
  validate :environment_not_library

  def system_template_exists
    if system_template && system_template.environment != self.environment
      errors.add(:system_template, _("name: %s doesn't exist ") % system_template.name)
    end
  end

  def environment_exists
    if environment.nil?
      errors.add(:environment, _("id: %s doesn't exist ") % environment_id)
    elsif environment.organization != self.organization
      errors.add(:environment, _("name: %s doesn't exist ") % environment.name)
    end
  end

  def environment_not_library
    errors.add(:base, _("Cannot create activation keys in Library environment ")) if environment and  environment.library?
  end

  # sets up system when registering with this activation key
  def apply_to_system(system)
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
    raise _("Not enough entitlements in pools (%d), required: %d, available: %d" % [entitlements.size, amount, total]) if amount != total
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
        raise _("Pool %s has no product associated" % pool.cp_id) unless pool.productId
        products[pool.productId] = {} unless products.key? pool.productId
        quantity = pool.quantity == -1 ? 999_999_999 : pool.quantity
        raise _("Unable to determine quantity for pool %s" % pool.cp_id) if quantity.nil?
        left = quantity - pool.consumed
        raise _("Number of consumed entitlements exceeded quantity for %s" % pool.cp_id) if left < 0
        products[pool.productId][pool.cp_id] = [pool.startDate_as_datetime, left]
      end

      # for each product consumer "allocate" amount of entitlements
      allocate = system.sockets.to_i
      Rails.logger.debug "Number of sockets for registration: #{allocate}"
      raise _("Number of sockets must be higher than 0 for system %s" % system.name) if allocate.nil? or allocate <= 0
      #puts products.inspect
      products.each do |productId, pools|
        # create two arrays - pool ids and remaining entitlements
        # subscription order is with most recent start or with the least pool number available
        pools_a = pools.to_a.sort { |a,b| (a[1][0] <=> b[1][0]).nonzero? || (a[0] <=> b[0]) }
        pools_ids = []
        pools_left = []
        pools_a.each { |p| pools_ids << p[0]; pools_left << p[1][1] }

        # calculate consupmtion array (throws an error when there are not enough entitlements)
        to_consume = calculate_consumption(allocate, pools_left)
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
    rescue Exception => e
      Rails.logger.error "Autosubscribtion failed, rolling back: #{already_subscribed.inspect}"
      already_subscribed.each do |entitlement_id|
        begin
          Rails.logger.debug "Rolling back: #{entitlement_id}"
          entitlements_array = system.unsubscribe entitlement_id
        rescue Exception => re
          Rails.logger.fatal "Rollback failed, skipping: #{re.message}"
        end
      end
      raise e
    end
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags organization_id
    [] #don't list tags for sync plans
  end

  def self.list_verbs global = false
    {
      :read_all => _("Read Activation Keys"),
      :manage_all => _("Administer Activation Keys")
    }.with_indifferent_access
  end

  def self.read_verbs
    [:read_all]
  end

  def self.no_tag_verbs
    ActivationKey.list_verbs.keys
  end

  def self.readable? org
    User.allowed_to?([:read_all, :manage_all], :activation_keys, nil, org)
  end

  def self.manageable? org
    User.allowed_to?([:manage_all], :activation_keys, nil, org)
  end

  def as_json(*args)
    ret = super(*args)
    ret[:pools] = pools.map do |pool|
      pool.as_json
    end
    ret
  end

  def extended_json
    to_ret = {:environment=>self.environment.name, :name_sort=>name.downcase}
    to_ret[:template] = self.system_template.name if self.system_template
    to_ret
  end

  private

  def validate_pools
    obsolete_pools = []
    self.pools.each do |pool|
      begin
        # This will hit candlepin; if it fails that means the
        # pool is no longer accessible.
        pool.productName
      rescue
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
