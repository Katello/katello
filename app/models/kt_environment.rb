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

require 'util/model_util'

class SelfReferenceEnvironmentValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:base] << _("Environment cannot be in its own promotion path") if record.priors.select(:id).include? record.id
  end
end

class PriorValidator < ActiveModel::Validator
  def validate(record)
    #need to ensure that prior
    #environment already does not have a successor
    #this is because in v1.0 we want
    # prior to have only one child (unless its the Library)
    has_no_prior = true
    if record.organization
      has_no_prior = record.organization.environments.reject{|env| env == record || env.prior != record.prior || env.prior == env.organization.library}.empty?
    end
    record.errors[:prior] << _("environment can only have one child") unless has_no_prior

    # only Library can have prior=nil
    record.errors[:prior] << _("environment required") unless !record.prior.nil? || record.library?
  end
end


class PathDescendentsValidator < ActiveModel::Validator
  def validate(record)
    #need to ensure that
    #environment is not duplicated in its path
    # We do not want circular dependencies
    return if record.prior.nil?
     record.errors[:prior] << _(" environment cannot be set to an environment already on its path") if is_duplicate? record.prior
  end

  def is_duplicate? record
    s = record.successor
    ret = [record.id]
    until s.nil?
      return true if ret.include? s.id
      ret << s.id
      s = s.successor
    end
    false
  end
end

class KTEnvironment < ActiveRecord::Base
  include Authorization
  include Glue::Candlepin::Environment if AppConfig.use_cp
  include Glue if AppConfig.use_cp
  set_table_name "environments"
  include Katello::LabelFromName
  acts_as_reportable

  belongs_to :organization, :inverse_of => :environments
  has_many :activation_keys, :dependent => :destroy, :foreign_key => :environment_id
  has_and_belongs_to_many :priors, {:class_name => "KTEnvironment", :foreign_key => :environment_id,
    :join_table => "environment_priors", :association_foreign_key => "prior_id", :uniq => true}
  has_and_belongs_to_many :successors, {:class_name => "KTEnvironment", :foreign_key => "prior_id",
    :join_table => "environment_priors", :association_foreign_key => :environment_id, :readonly => true}
  has_many :system_templates, :dependent => :destroy, :class_name => "SystemTemplate", :foreign_key => :environment_id

  has_many :environment_products, :class_name => "EnvironmentProduct", :foreign_key => "environment_id", :dependent => :destroy, :uniq=>true
  has_many :products, :uniq => true, :through => :environment_products  do
    def <<(*items)
      super( items - proxy_owner.environment_products.collect{|ep| ep.product} )
    end
  end

  has_many :repositories, :through => :environment_products, :source => :repositories

  has_many :systems, :inverse_of => :environment, :dependent => :destroy,  :foreign_key => :environment_id
  has_many :working_changesets, :conditions => ["state != '#{Changeset::PROMOTED}'"], :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment

  has_many :working_deletion_changesets, :conditions => ["state != '#{Changeset::DELETED}'"], :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"DeletionChangeset", :dependent => :destroy, :inverse_of => :environment
  has_many :working_promotion_changesets, :conditions => ["state != '#{Changeset::PROMOTED}'"], :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"PromotionChangeset", :dependent => :destroy, :inverse_of => :environment

  has_many :changeset_history, :conditions => {:state => Changeset::PROMOTED}, :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment

  scope :completer_scope, lambda { |options| where('organization_id = ?', options[:organization_id])}

  validates :name, :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library" }, :unless => :library?
  validates :label, :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library" }, :unless => :library?
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("of environment must be unique within one organization")
  validates_uniqueness_of :label, :scope => :organization_id, :message => N_("of environment must be unique within one organization")
  validates_presence_of :organization
  validates :name, :presence => true, :katello_name_format => true
  validates :label, :presence => true, :katello_label_format => true

  validates :description, :katello_description_format => true
  validates_with PriorValidator
  validates_with PathDescendentsValidator

  before_destroy :confirm_last_env
  after_save :update_related_index
  after_destroy :delete_related_index
  after_destroy :unset_users_with_default
   ERROR_CLASS_NAME = "Environment"


  def library?
    self.library
  end

  def successor
    return self.successors[0] unless self.library?
    self.organization.promotion_paths()[0][0] if !self.organization.promotion_paths().empty?
  end

  def display_name
    self.name
  end

  def prior
    self.priors[0]
  end

  def prior=(env_id)
    self.priors.clear
    return if env_id.nil? || env_id == ""
    prior_env = KTEnvironment.find env_id
    self.priors << prior_env unless prior_env.nil?
  end

  def path
    s = self.successor
    ret = [self]
    until s.nil?
      raise "Environment path has duplicates!!. #{self}. Duplicate => #{ret}. Path => #{s}" if ret.include? s
      ret << s
      s = s.successor
    end
    ret
  end

  #is the environment currently being promoted to
  def promoting_to?
    self.promoting.exists?
  end

  #list changesets promoting
  def promoting
      Changeset.joins(:task_status).where('changesets.environment_id' => self.id,
        'task_statuses.state' => [TaskStatus::Status::WAITING,  TaskStatus::Status::RUNNING])
  end

  def confirm_last_env
    # when deleting env while org is deleted, self.organization is nil (and we
    # can't do this logic properly)
    # we don't have to check this anyway, all environments will be destroyed
    # with the org.
    return true unless self.organization

    return true if successor.nil?
    errors.add :base,
               _("Environment %s has a successor.  Only the last environment on a path can be deleted") % self.name
    return false
  end

  #Unlike path which only gives the path from this environment going forward
  #  Get the full path, that is go to the HEAD of the path this environment is on
  #  and then give me that entire path
  def full_path
    p = self
    until p.prior.nil? or p.prior.library
      p = p.prior
    end
    p.prior.nil? ? p.path : [p.prior] + p.path
  end

  def available_products
    if self.prior.library
      # if there is no prior, then the prior is the Library, which has all products
      prior_products = self.organization.library.products
    else
      prior_products = self.prior.products
    end
    return prior_products - self.products
  end


  def as_json options = {}
    to_ret = self.attributes
    to_ret['prior'] = self.prior &&  self.prior.name
    to_ret['prior_id'] = self.prior &&  self.prior.id
    to_ret['organization'] = self.organization &&  self.organization.name
    to_ret
  end

  def key_for(item)
    "environment_#{id}_#{item}"
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags org_id
    KTEnvironment.where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.tags(ids)
    KTEnvironment.where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
  end


  def package_groups search_args = {}
    groups = []
    self.products.each do |prod|
      groups << prod.package_groups(self, search_args)
    end
    groups.flatten(1)
  end

  def package_group_categories search_args = {}
    categories = []
    self.products.each do |prod|
      categories << prod.package_group_categories(self, search_args)
    end
    categories.flatten(1)
  end

  def find_packages_by_name name
    self.products.collect do |prod|
      prod.find_packages_by_name(self, name).collect do |p|
        p[:product_id] = prod.cp_id
        p
      end
    end.flatten(1)
  end

  def find_packages_by_nvre name, version, release, epoch
    self.products.collect do |prod|
      prod.find_packages_by_nvre(self, name, version, release, epoch).collect do |p|
        p[:product_id] = prod.cp_id
        p
      end
    end.flatten(1)
  end

  def find_latest_packages_by_name name

    packs = self.products.collect do |prod|
      prod.find_latest_packages_by_name(self, name).collect do |pack|
        pack[:product_id] = prod.cp_id
        pack
      end
    end.flatten(1)

    Katello::PackageUtils.find_latest_packages packs
  end

  def get_distribution id
    self.products.collect do |prod|
      prod.get_distribution(self, id)
    end.flatten(1)
  end

  #Permissions
  scope :changesets_readable, lambda {|org| authorized_items(org, [:delete_changesets, :promote_changesets, :manage_changesets, :read_changesets])}
  scope :content_readable, lambda {|org| authorized_items(org, [:read_contents])}
  scope :systems_readable, lambda{|org|
    if  org.systems_readable?
      where(:organization_id => org)
    else
      authorized_items(org, SYSTEMS_READABLE)
    end
  }
  scope :systems_registerable, lambda { |org|
    if org.systems_registerable?
      where(:organization_id => org)
    else
      authorized_items(org, [:register_systems])
    end
  }

  def self.any_viewable_for_promotions? org
    return false if !AppConfig.katello?
    User.allowed_to?(CHANGE_SETS_READABLE + CONTENTS_READABLE, :environments, org.environment_ids, org, true)
  end

  def self.any_contents_readable? org, skip_library=false
    ids = org.environment_ids
    ids = ids - [org.library.id] if skip_library
    User.allowed_to?(CONTENTS_READABLE, :environments, ids, org, true)
  end

  def viewable_for_promotions?
    return false if !AppConfig.katello?
    User.allowed_to?(CHANGE_SETS_READABLE + CONTENTS_READABLE, :environments, self.id, self.organization)
  end

  def any_operation_readable?
    return false if !AppConfig.katello?
    User.allowed_to?(self.class.list_verbs.keys, :environments, self.id, self.organization) ||
        self.organization.systems_readable? || self.organization.any_systems_registerable? ||
        ActivationKey.readable?(self.organization)
  end

  def changesets_promotable?
    return false if !AppConfig.katello?
    User.allowed_to?([:promote_changesets], :environments, self.id,
                              self.organization)
  end

  def changesets_deletable?
    return false if !AppConfig.katello?
    User.allowed_to?([:delete_changesets], :environments, self.id,
                              self.organization)
  end

  CHANGE_SETS_READABLE = [:manage_changesets, :read_changesets, :promote_changesets, :delete_changesets]
  def changesets_readable?
    return false if !AppConfig.katello?
    User.allowed_to?(CHANGE_SETS_READABLE, :environments,
                              self.id, self.organization)
  end

  def changesets_manageable?
    return false if !AppConfig.katello?
    User.allowed_to?([:manage_changesets], :environments, self.id,
                              self.organization)
  end

  CONTENTS_READABLE = [:read_contents]
  def contents_readable?
    return false if !AppConfig.katello?
    User.allowed_to?(CONTENTS_READABLE, :environments, self.id,
                              self.organization)
  end


  SYSTEMS_READABLE = [:read_systems, :register_systems, :update_systems, :delete_systems]
  def systems_readable?
    self.organization.systems_readable? ||
        User.allowed_to?(SYSTEMS_READABLE, :environments, self.id, self.organization)
  end

  def systems_editable?
    User.allowed_to?([:update_systems], :organizations, nil, self.organization) ||
        User.allowed_to?([:update_systems], :environments, self.id, self.organization)
  end

  def systems_deletable?
    User.allowed_to?([:delete_systems], :organizations, nil, self.organization) ||
        User.allowed_to?([:delete_systems], :environments, self.id, self.organization)
  end

  def systems_registerable?
    self.organization.systems_registerable? ||
        User.allowed_to?([:register_systems], :environments, self.id, self.organization)
  end


  def self.authorized_items org, verbs, resource = :environments
    raise "scope requires an organization" if org.nil?
    if User.allowed_all_tags?(verbs, resource, org)
       where(:organization_id => org)
    else
      where("environments.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
    end
  end

  def self.list_verbs global = false
    if AppConfig.katello?
      {
      :read_contents => _("Read Environment Contents"),
      :read_systems => _("Read Systems in Environment"),
      :register_systems =>_("Register Systems in Environment"),
      :update_systems => _("Modify Systems in Environment"),
      :delete_systems => _("Remove Systems in Environment"),
      :read_changesets => _("Read Changesets in Environment"),
      :manage_changesets => _("Administer Changesets in Environment"),
      :promote_changesets => _("Promote Content to Environment"),
      :delete_changesets => _("Delete Content from Environment")
      }.with_indifferent_access
    else
      {
      :read_contents => _("Read Environment Contents"),
      :read_systems => _("Read Systems in Environment"),
      :register_systems =>_("Register Systems in Environment"),
      :update_systems => _("Modify Systems in Environment"),
      :delete_systems => _("Remove Systems in Environment"),
      }.with_indifferent_access
    end
  end

  def self.read_verbs
    if AppConfig.katello?
      [:read_contents, :read_changesets, :read_systems]
    else
      [:read_contents, :read_systems]
    end
  end


  def update_related_index
    if self.name_changed?
      self.organization.reload #must reload organization, otherwise old name is saved
      self.organization.update_index
      ActivationKey.index.import(self.activation_keys) if !self.activation_keys.empty?
    end
  end

  def delete_related_index
    self.organization.update_index if self.organization
  end

  def unset_users_with_default
    users = User.find_by_default_environment(self.id)
    users.each do |u|
      u.default_environment = nil
      Notify.message _("Your default environment has been removed. Please choose another one."),
                     :user => u, :organization => self.organization
    end
  end

  # Katello, which understands repository content and promotion, provides release versions based upon
  # enabled repos. Headpin, which does not traverse products to the repo level, exposes all release
  # versions in the manifest.
  def available_releases
    if AppConfig.katello?
      self.repositories.enabled.map(&:minor).compact.uniq.sort
    else
      self.organization.redhat_provider.available_releases
    end
  end

end
