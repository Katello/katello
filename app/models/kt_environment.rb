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

class KTEnvironment < ActiveRecord::Base

  include Authorization::Environment
  include Glue::ElasticSearch::Environment if Katello.config.use_elasticsearch
  include Glue if Katello.config.use_cp || Katello.config.use_pulp

  set_table_name "environments"
  include Katello::LabelFromName
  include Ext::PermissionTagCleanup
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
      # TODO:  RAILS32 Convert this to @association.owner
      if @association.nil?
        owner = @owner
      else
        owner = @association.owner
      end
      super( items - owner.environment_products.collect{|ep| ep.product} )
    end
  end

  has_many :repositories, :through => :environment_products, :source => :repositories

  has_many :systems, :inverse_of => :environment, :dependent => :destroy,  :foreign_key => :environment_id
  has_many :distributors, :inverse_of => :environment, :dependent => :destroy,  :foreign_key => :environment_id
  has_many :working_changesets, :conditions => ["state != '#{Changeset::PROMOTED}'"], :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment

  has_many :working_deletion_changesets, :conditions => ["state != '#{Changeset::DELETED}'"], :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"DeletionChangeset", :dependent => :destroy, :inverse_of => :environment
  has_many :working_promotion_changesets, :conditions => ["state != '#{Changeset::PROMOTED}'"], :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"PromotionChangeset", :dependent => :destroy, :inverse_of => :environment

  has_many :changeset_history, :conditions => {:state => Changeset::PROMOTED}, :foreign_key => :environment_id, :dependent => :destroy, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment

  has_many :content_view_version_environments, :foreign_key=>:environment_id
  has_many :content_view_versions, :through=>:content_view_version_environments, :inverse_of=>:environments

  has_one :default_content_view, :class_name => "ContentView", :foreign_key => :environment_default_id

  has_many :users, :foreign_key => :default_environment_id, :inverse_of => :default_environment, :dependent => :nullify

  scope :completer_scope, lambda { |options| where('organization_id = ?', options[:organization_id])}

  validates :name, :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library" }, :unless => :library?
  validates :label, :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library" }, :unless => :library?
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("of environment must be unique within one organization")
  validates_uniqueness_of :label, :scope => :organization_id, :message => N_("of environment must be unique within one organization")
  validates_presence_of :organization
  validates :name, :presence => true
  validates :label, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_with Validators::PriorValidator
  validates_with Validators::PathDescendentsValidator

  after_create :create_default_content_view
  before_destroy :confirm_last_env

  after_destroy :unset_users_with_default
   ERROR_CLASS_NAME = "Environment"

  def library?
    self.library
  end

  def default_view_version
    self.default_content_view.version(self)
  end

  def content_views(reload = false)
    @content_views = nil if reload
    @content_views ||= ContentView.joins(:content_view_versions => :content_view_version_environments).
        where("content_view_version_environments.environment_id" => self.id)
  end

  def content_view_environment
    self.default_content_view.content_view_environments.first
  end

  def successor
    return self.successors[0] unless self.library?
    self.organization.promotion_paths()[0][0] if !self.organization.promotion_paths().empty?
  end

  def display_name
    self.name
  end

  def to_s
    display_name
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

  def unset_users_with_default
    users = User.with_default_environment(self.id)
    users.each do |u|
      Notify.message _("Your default environment has been removed. Please choose another one."),
                     :user => u, :organization => self.organization
    end
  end

  # Katello, which understands repository content and promotion, provides release versions based upon
  # enabled repos. Headpin, which does not traverse products to the repo level, exposes all release
  # versions in the manifest.
  def available_releases
    if Katello.config.katello?
      self.repositories.enabled.map(&:minor).compact.uniq.sort
    else
      self.organization.redhat_provider.available_releases
    end
  end

  def create_default_content_view
    if self.default_content_view.nil?
      content_view = build_default_content_view(:name=>"Default View for #{self.name}",
                                       :organization=>self.organization, :default=>true)

      content_view_version = ContentViewVersion.new(:version => 1, :content_view => content_view)
      content_view_version.environments << self

      content_view_version.save! # saves both content_view and content_view_version
    end
  end
end
