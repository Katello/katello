#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
class ActivationKey < Katello::Model
  self.include_root_in_json = false

  include Glue::Candlepin::ActivationKey if Katello.config.use_cp
  include Glue::ElasticSearch::ActivationKey if Katello.config.use_elasticsearch
  include Glue if Katello.config.use_cp
  include Katello::Authorization::ActivationKey
  include Ext::LabelFromName

  belongs_to :organization, :inverse_of => :activation_keys
  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :activation_keys
  belongs_to :user, :inverse_of => :activation_keys, :class_name => "::User"
  belongs_to :content_view, :inverse_of => :activation_keys

  has_many :key_system_groups, :class_name => "Katello::KeySystemGroup", :dependent => :destroy
  has_many :system_groups, :through => :key_system_groups

  has_many :system_activation_keys, :class_name => "Katello::SystemActivationKey", :dependent => :destroy
  has_many :systems, :through => :system_activation_keys

  before_validation :set_default_content_view, :unless => :persisted?
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates :label, :uniqueness => {:scope => :organization_id}, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates :name, :presence => true
  validates :name, :uniqueness => {:scope => :organization_id}
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validate :environment_exists
  validates_each :usage_limit do |record, attr, value|
    if value.nil?
      record.errors[attr] << _("cannot be nil")
    elsif value > -1 && value < record.systems.length
      # we don't let users to set usage limit lower than current in-use
      record.errors[attr] << _("cannot be lower than current usage count (%s)" % record.systems.length)
    end
  end
  validates_with Validators::ContentViewEnvironmentValidator

  scope :in_environment, lambda { |env| where(:environment_id => env) }

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :organization_id, :complete_value => true

  def environment_exists
    if environment_id && environment.nil?
      errors.add(:environment, _("ID: %s doesn't exist ") % environment_id)
    elsif !environment.nil? && environment.organization != self.organization
      errors.add(:environment, _("name: %s doesn't exist ") % environment.name)
    end
  end

  def usage_count
    system_activation_keys.count
  end

  # sets up system when registering with this activation key - must be executed in a transaction
  def apply_to_system(system)
    if !usage_limit.nil? && usage_limit != -1 && usage_count >= usage_limit
      fail Errors::UsageLimitExhaustedException, _("Usage limit (%{limit}) exhausted for activation key '%{name}'") % {:limit => usage_limit, :name => name}
    end
    system.environment_id = self.environment_id if self.environment_id
    system.content_view_id = self.content_view_id if self.content_view_id
    system.system_activation_keys.build(:activation_key => self)
  end

  def calculate_consumption(product, pools, allocate)
    pools = pools.sort_by { |pool| [pool.start_date, pool.cp_id] }
    consumption = {}

    if product.provider.redhat_provider?
      pools.each do |pool|
        consumption[pool] ||= 0
        consumption[pool] += 1
      end
    else
      consumption[pools.first] = 1
    end
    return consumption
  end

  # subscribe to each product according the entitlements remaining
  # TODO: break up method
  # rubocop:disable MethodLength
  def subscribe_system(system)
    already_subscribed = []
    begin
      # sanity check before we start subscribing
      self.pools.each do |pool|
        fail _("Pool %s has no product associated") % pool.cp_id unless pool.product_id
        fail _("Unable to determine quantity for pool %s") % pool.cp_id unless pool.quantity
      end

      allocate = system.sockets.to_i
      Rails.logger.debug "Number of sockets for registration: #{allocate}"
      fail _("Number of sockets must be higher than 0 for system %s") % system.name if allocate <= 0

      # we sort just to make the order deterministig.
      self.pools.group_by(&:product_id).sort_by(&:first).each do |product_id, pools|
        product = Product.find_by_cp_id(product_id, self.organization)
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
          system.unsubscribe(entitlement_id)
        rescue => re
          Rails.logger.fatal "Rollback failed, skipping: #{re.message}"
        end
      end
      raise e
    end
  end

  private

  def set_default_content_view
    if self.environment && self.content_view.nil?
      self.content_view = self.environment.try(:default_content_view)
    end
  end

  def self.humanize_class_name
    _("Activation Keys")
  end

end
end
