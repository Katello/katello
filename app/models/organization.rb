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


class Organization < ActiveRecord::Base
  include Glue::Candlepin::Owner if Katello.config.use_cp
  include Glue if Katello.config.use_cp
  include Ext::Authorization
  include Ext::IndexedModel
  include Ext::PermissionTagCleanup

  index_options :extended_json=>:extended_index_attrs,
                :json=>{:except=>[:debug_cert, :events]},
                :display_attrs=>[:name, :description, :environment]




  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :label, :type => 'string', :index => :not_analyzed
  end

  has_many :activation_keys, :dependent => :destroy
  has_many :providers, :dependent => :destroy
  has_many :products, :through => :providers
  has_many :environments, :class_name => "KTEnvironment", :conditions => {:library => false}, :dependent => :destroy, :inverse_of => :organization
  has_one :library, :class_name =>"KTEnvironment", :conditions => {:library => true}, :dependent => :destroy
  has_many :filters, :dependent => :destroy, :inverse_of => :organization
  has_many :gpg_keys, :dependent => :destroy, :inverse_of => :organization
  has_many :permissions, :dependent => :destroy, :inverse_of => :organization
  has_many :sync_plans, :dependent => :destroy, :inverse_of => :organization
  has_many :system_groups, :dependent => :destroy, :inverse_of => :organization
  serialize :system_info_keys, Array

  attr_accessor :statistics

  # Organizations which are being deleted (or deletion failed) can be filtered out with this scope.
  scope :without_deleting, where(:task_id => nil)
  scope :having_name_or_label, lambda { |name_or_label| { :conditions => ["name = :id or label = :id", {:id=>name_or_label}] } }

  before_create :create_library
  before_create :create_redhat_provider

  validates :name, :uniqueness => true, :presence => true
  validates :label, :uniqueness => { :message => _("already exists (including organizations being deleted)") },
            :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validate :unique_name_and_label

  before_save { |o| o.system_info_keys = Array.new unless o.system_info_keys }

  if Katello.config.use_cp
    before_validation :create_label, :on => :create

    def create_label
      self.label = self.name.tr(' ', '_') if self.label.blank? && self.name.present?
    end
  end

  # Ensure that the name and label namespaces do not overlap
  def unique_name_and_label
    if new_record? and Organization.where("name = ? OR label = ?", label, name).any?
      errors.add(:organization, _("Names and labels must be unique across all organizations"))
    elsif label_changed? and Organization.where("id != ? AND name = ?", id, label).any?
      errors.add(:label, _("Names and labels must be unique across all organizations"))
    elsif name_changed? and Organization.where("id != ? AND label = ?", id, name).any?
      errors.add(:name, _("Names and labels must be unique across all organizations"))
    else
      true
    end
  end

  def systems
    System.where(:environment_id => environments)
  end

  def promotion_paths
    #I'm sure there's a better way to do this
    self.environments.joins(:priors).where("prior_id = #{self.library.id}").collect do |env|
      env.path
    end
  end

  def redhat_provider
    self.providers.redhat.first
  end

  def create_library
    self.library = KTEnvironment.new(:name => "Library",:label => "Library",  :library => true, :organization => self)
  end

  def create_redhat_provider
    self.providers << ::Provider.new(:name => "Red Hat", :provider_type=> ::Provider::REDHAT, :organization => self)
  end

  # TODO - this code seems to be dead
  def validate_destroy current_org
    def_error = _("Could not delete organization '%s'.")  % [self.name]
    if (current_org == self)
      [def_error, _("The current organization cannot be deleted. Please switch to a different organization before deleting.")]
    elsif (Organization.count == 1)
      [def_error, _("At least one organization must exist.")]
    end
  end

  def being_deleted?
    ! self.task_id.nil?
  end

  #permissions
  scope :readable, lambda {authorized_items(READ_PERM_VERBS)}

  def self.creatable?
    User.allowed_to?([:create], :organizations)
  end

  def editable?
      User.allowed_to?([:update, :create], :organizations, nil, self)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :organizations)
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :organizations,nil, self)
  end

  def self.any_readable?
    Organization.readable.count > 0
  end

  def environments_manageable?
    User.allowed_to?([:update, :create], :organizations, nil, self)
  end

  SYSTEMS_READABLE = [:read_systems, :register_systems, :update_systems, :delete_systems]

  def systems_readable?
    User.allowed_to?(SYSTEMS_READABLE, :organizations, nil, self)
  end

  def systems_deletable?
    User.allowed_to?([:delete_systems], :organizations, nil, self)
  end

  def systems_registerable?
    User.allowed_to?([:register_systems], :organizations, nil, self)
  end


  def any_systems_registerable?
    systems_registerable? || User.allowed_to?([:register_systems], :environments, environment_ids, self, true)
  end


  def gpg_keys_manageable?
    User.allowed_to?([:gpg], :organizations, nil, self)
  end

  def self.list_verbs global = false
    if Katello.config.katello?
      org_verbs = {
        :update => _("Modify Organization and Administer Environments"),
        :read => _("Read Organization"),
        :read_systems => _("Read Systems"),
        :register_systems =>_("Register Systems"),
        :update_systems => _("Modify Systems"),
        :delete_systems => _("Delete Systems"),
        :sync => _("Sync Products"),
        :gpg => _("Administer GPG Keys")
     }
    else
      org_verbs = {
        :update => _("Modify Organization and Administer Environments"),
        :read => _("Read Organization"),
        :read_systems => _("Read Systems"),
        :register_systems =>_("Register Systems"),
        :update_systems => _("Modify Systems"),
        :delete_systems => _("Delete Systems"),
     }
    end
    org_verbs.merge!({
    :create => _("Administer Organization"),
    :delete => _("Delete Organization")
    }) if global
    org_verbs.with_indifferent_access

  end

  def self.read_verbs
    [:read, :read_systems]
  end


  def self.no_tag_verbs
    [:create]
  end

  def syncable?
    User.allowed_to?(SYNC_PERM_VERBS, :organizations, nil, self)
  end

  private

  def self.authorized_items verbs, resource = :organizations
    if !User.allowed_all_tags?(verbs, resource)
      where("organizations.id in (#{User.allowed_tags_sql(verbs, resource)})")
    end
  end

  READ_PERM_VERBS = [:read, :create, :update, :delete]
  SYNC_PERM_VERBS = [:sync]


  def extended_index_attrs
    {:name_sort=>name.downcase, :environment=>self.environments.collect{|e| e.name}}
  end

end
