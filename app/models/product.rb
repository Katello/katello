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

class LockerPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must contain 'Locker'" if value.select {|e| e.locker}.empty?
  end
end

class Product < ActiveRecord::Base
  include Glue::Candlepin::Product if AppConfig.use_cp
  include Glue::Pulp::Repos if (AppConfig.use_cp and AppConfig.use_pulp)
  include Glue if AppConfig.use_cp
  include Authorization
  include AsyncOrchestration

  has_and_belongs_to_many :environments, { :class_name => "KPEnvironment", :uniq => true }
  has_and_belongs_to_many :changesets
  belongs_to :provider, :inverse_of => :products
  belongs_to :sync_plan, :inverse_of => :products

  validates :description, :katello_description_format => true
  validates :environments, :locker_presence => true
  validates :name, :presence => true, :katello_name_format => true

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :multiplier, :complete_value => true

  def initialize(attrs = nil)

    unless attrs.nil?
      attrs = attrs.with_indifferent_access

      #rename "id" to "cp_id" (activerecord and candlepin variable name conflict)
      if attrs.has_key?(:id)
        if !attrs.has_key?(:cp_id)
          attrs[:cp_id] = attrs[:id]
        end
        attrs.delete(:id)
      end

      # ugh. hack-ish. otherwise we have to modify code every time things change on cp side
      attrs = attrs.reject do |k, v|
        !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
      end
    end

    super(attrs)
  end

  def organization
    provider.organization
  end

  def locker
    environments.select {|e| e.locker}.first
  end

  def plan_name
    return sync_plan.name if sync_plan
    N_('None')
  end

  def to_json(options={})
    json = self.as_json(options.merge(:except => :cp_id))
    json = json.merge(:sync_state => self.sync_state,
                      :last_sync => self.last_sync,
                      :productContent => self.productContent,
                      :multiplier => self.multiplier,
                      :attributes => self.attrs,
                      :id => self.cp_id)
    ActiveSupport::JSON.encode(json)
  end

  #Permissions

  scope :readable, lambda {|org| authorized_items(org, READ_PERM_VERBS)}
  scope :syncable, lambda {|org| sync_items(org)}

  protected

  def self.authorized_items org, verbs, resource = :providers
     raise "scope requires an organization" if org.nil?
     if User.allowed_all_tags?(verbs, resource, org)
       joins(:provider).where('providers.organization_id' => org)
     else
       joins(:provider).where("providers.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
     end
  end


  def self.sync_items org
    org.syncable? ? (joins(:provider).where('providers.organization_id' => org)) : where("0=1")
  end

  READ_PERM_VERBS = [:read, :create, :update, :delete]

end
