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

class SystemGroup < ActiveRecord::Base


  include Glue::Pulp::ConsumerGroup if (AppConfig.use_pulp)
  include Glue
  include Authorization
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :json=>{},
                :display_attrs=>[:name, :description, :system]

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :name_autocomplete, :type=>'string', :analyzer=>'autcomplete_name_analyzer'
    indexes :locked, :type=>'boolean'
  end

  update_related_indexes :systems, :name

  has_many :key_system_groups, :dependent => :destroy
  has_many :activation_keys, :through => :key_system_groups

  has_many :system_system_groups, :dependent => :destroy
  has_many :systems, {:through => :system_system_groups, :before_add => :add_pulp_consumer_group,
           :before_remove => :remove_pulp_consumer_group}.merge(update_association_indexes)

  validates :pulp_id, :presence => true
  validates :name, :presence => true, :katello_name_format => true
  validates_presence_of :organization_id, :message => N_("Organization cannot be blank.")
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("Name must be unique within one organization")
  validates_uniqueness_of :pulp_id, :message=> N_("Pulp identifier must be unique.")


  belongs_to :organization

  before_validation(:on=>:create) do
    self.pulp_id ||= "#{self.organization.cp_key}-#{self.name}-#{SecureRandom.hex(4)}"
  end

  scope :readable, lambda { |org|
    items(org, READ_PERM_VERBS)
  }
  scope :editable, lambda { |org|
    items(org, [:update])
  }
  scope :systems_readable, lambda{|org|
    if  org.systems_readable?
      where(:organization_id => org)
    else
      SystemGroup.items(org, SYSTEM_READ_PERMS)
    end
  }

  def self.creatable? org
    User.allowed_to?([:create], :system_groups, nil, org)
  end

  def self.any_readable? org
    User.allowed_to?(READ_PERM_VERBS, :system_groups, nil, org)
  end

  def system_readable?
    User.allowed_to?(SYSTEM_READ_PERMS, :system_groups, self.id, self.organization)
  end

  def system_deletable?
    User.allowed_to?([:delete_systems], :system_groups, self.id, self.organization)
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :system_groups, self.id, self.organization)
  end

  def editable?
    User.allowed_to?([:update, :create], :system_groups, self.id, self.organization)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :system_groups, self.id, self.organization)
  end

  def locking?
    User.allowed_to?([:locking], :system_groups, self.id, self.organization)
  end

  def self.list_tags org_id
    SystemGroup.select('id,name').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.tags(ids)
    select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.list_verbs  global = false
    {
       :create => _("Administer System Groups"),
       :read => _("Read System Group"),
       :update => _("Modify System Group details and system membership"),
       :delete => _("Delete System Group"),
       :locking => _("Lock/Unlock System Group"),
       :read_systems => _("Read Systems in System Group"),
       :update_systems => _("Modify Systems in System Group"),
       :delete_systems => _("Delete Systems in System Group")
    }.with_indifferent_access
  end

  def self.read_verbs
    [:read]
  end

  def self.no_tag_verbs
    [:create]
  end


  def extended_index_attrs
    {:name_sort=>name.downcase, :name_autocomplete=>self.name,
     :system=>self.systems.collect{|s| s.name}
    }
  end

  def lock_check
    raise _("Group membership cannot be changed while locked.") if self.locked
  end

  private

  def add_pulp_consumer_group record
    lock_check
    self.add_consumers([record.uuid])
  end

  def remove_pulp_consumer_group record
    lock_check
    self.del_consumers([record.uuid])
  end

  def self.items org, verbs
    raise "scope requires an organization" if org.nil?
    resource = :system_groups
    if User.allowed_all_tags?(verbs, resource, org)
       where(:organization_id => org)
    else
      where("system_groups.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
    end
  end

  READ_PERM_VERBS = SystemGroup.list_verbs.keys
  SYSTEM_READ_PERMS = [:read_systems, :update_systems, :delete_systems]

end
