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
class KTEnvironment < Katello::Model
  self.include_root_in_json = false
  include Authorization::LifecycleEnvironment
  include Glue::ElasticSearch::Environment if Katello.config.use_elasticsearch

  self.table_name = "katello_environments"
  include Ext::LabelFromName

  # RAILS3458: before_destroys before associations. see http://tinyurl.com/rails3458
  before_destroy :is_deletable?
  before_destroy :delete_core_environments
  before_destroy :delete_default_view_version

  belongs_to :organization, :class_name => "Organization", :inverse_of => :environments
  has_many :activation_keys, :class_name => "Katello::ActivationKey",
           :dependent => :destroy, :foreign_key => :environment_id
  # rubocop:disable HasAndBelongsToMany
  # TODO: change these into has_many associations
  has_and_belongs_to_many :priors, { :class_name => "Katello::KTEnvironment", :foreign_key => :environment_id,
                                     :join_table => "katello_environment_priors",
                                     :association_foreign_key => "prior_id", :uniq => true }
  has_and_belongs_to_many :successors, { :class_name => "Katello::KTEnvironment", :foreign_key => "prior_id",
                                         :join_table => "katello_environment_priors",
                                         :association_foreign_key => :environment_id, :readonly => true }

  has_many :repositories, :class_name => "Katello::Repository", dependent: :destroy, foreign_key: :environment_id
  has_many :systems, :class_name => "Katello::System", :inverse_of => :environment,
           :dependent => :destroy, :foreign_key => :environment_id
  has_many :distributors, :class_name => "Katello::Distributor", :inverse_of => :environment,
           :dependent => :destroy, :foreign_key => :environment_id
  has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment",
           :foreign_key => :environment_id, :inverse_of => :environment, :dependent => :destroy
  has_many :content_view_puppet_environments, :class_name => "Katello::ContentViewPuppetEnvironment",
           :foreign_key => :environment_id, :inverse_of => :environment, :dependent => :destroy
  has_many :content_view_versions, :through => :content_view_environments, :inverse_of => :environments
  has_many :content_views, :through => :content_view_environments, :inverse_of => :environments
  has_many :content_view_histories, :class_name => "Katello::ContentViewHistory", :dependent => :destroy,
           :inverse_of => :environment, :foreign_key => :katello_environment_id

  has_many :users, :foreign_key => :default_environment_id, :inverse_of => :default_environment, :dependent => :nullify

  scope :completer_scope, lambda { |options=nil| where('organization_id = ?', options[:organization_id]) if options[:organization_id].present? }
  scope :non_library, where(library: false)
  scope :library, where(library: true)

  validates :organization, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                      :message => N_("of environment must be unique within one organization")},
                   :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library", :unless => :library? }
  validates :label, :presence => true, :uniqueness => {:scope => :organization_id,
                                                       :message => N_("of environment must be unique within one organization")},
                    :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library", :unless => :library?},
                    :exclusion => { :in => [ContentView::CONTENT_DIR], :message => N_(": '%s' is a built-in environment") % ContentView::CONTENT_DIR }
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_with Validators::PriorValidator
  validates_with Validators::PathDescendentsValidator

  has_many :capsule_lifecycle_environments, :foreign_key => :lifecycle_environment_id,
           :dependent => :destroy

  scope(:not_in_capsule,
        lambda do |capsule|
          select("DISTINCT #{KTEnvironment.table_name}.*").
              joins(%{LEFT OUTER JOIN #{CapsuleLifecycleEnvironment.table_name} ON ( "#{CapsuleLifecycleEnvironment.table_name}"."lifecycle_environment_id" = "#{KTEnvironment.table_name}"."id")}).
              where(%{"#{CapsuleLifecycleEnvironment.table_name}"."capsule_id" IS NULL
                     OR "#{CapsuleLifecycleEnvironment.table_name}"."capsule_id" != ?}, capsule.id)
        end)

  after_create :add_to_default_capsule
  after_destroy :unset_users_with_default

  ERROR_CLASS_NAME = "Environment"

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :organization_id, :complete_value => true

  def library?
    self.library
  end

  def default_content_view
    self.default_content_view_version.try(:content_view, nil)
  end

  def default_content_view_version
    return nil unless self.organization.default_content_view
    self.organization.default_content_view.version(self)
  end

  def content_view_environment
    return nil unless self.default_content_view
    self.default_content_view.content_view_environments.where(:environment_id => self.id).first
  end

  def successor
    return self.successors[0] unless self.library?
    self.organization.promotion_paths[0][0] if !self.organization.promotion_paths.empty?
  end

  def display_name
    self.name
  end

  def to_s
    display_name
  end

  # for multiselect helper in foreman
  def to_label
    return "#{name} (#{organization.title})" if organization && ::Organization.current.nil?
    name
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
      fail "Environment path has duplicates!!. #{self}. Duplicate => #{ret}. Path => #{s}" if ret.include? s
      ret << s
      s = s.successor
    end
    ret
  end

  #is the environment currently being promoted to
  def promoting_to?
    self.promoting.exists?
  end

  def is_deletable?
    return true if self.organization.nil? || self.organization.being_deleted?

    if library?
      errors.add :base, _("Library environments may not be deleted.")
      return false
    elsif !successor.nil?
      errors.add :base, _("Environment %s has a successor.  Only the last environment on a path can be deleted") % self.name
      return false
    end

    return true
  end

  #Unlike path which only gives the path from this environment going forward
  #  Get the full path, that is go to the HEAD of the path this environment is on
  #  and then give me that entire path
  def full_path
    p = self
    until p.prior.nil? || p.prior.library
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

  def products
    self.library? ? Product.in_org(self.organization) : Product.where(id: repositories.map(&:product_id))
  end

  def puppet_repositories
    Repository.readable.where(:content_type => Katello::Repository::PUPPET_TYPE)
  end

  def as_json(options = {})
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
  def self.list_tags(org_id)
    KTEnvironment.where(:organization_id => org_id).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.tags(ids)
    KTEnvironment.where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def package_groups(search_args = {})
    groups = []
    self.products.each do |prod|
      groups << prod.package_groups(self, search_args)
    end
    groups.flatten(1)
  end

  def package_group_categories(search_args = {})
    categories = []
    self.products.each do |prod|
      categories << prod.package_group_categories(self, search_args)
    end
    categories.flatten(1)
  end

  def find_packages_by_name(name)
    products = self.products.collect do |prod|
      prod.find_packages_by_name(self, name).collect do |p|
        p[:product_id] = prod.cp_id
        p
      end
    end
    products.flatten(1)
  end

  def find_packages_by_nvre(name, version, release, epoch)
    products = self.products.collect do |prod|
      prod.find_packages_by_nvre(self, name, version, release, epoch).collect do |p|
        p[:product_id] = prod.cp_id
        p
      end
    end
    products.flatten(1)
  end

  def find_latest_packages_by_name(name)

    packs = self.products.collect do |prod|
      prod.find_latest_packages_by_name(self, name).collect do |pack|
        pack[:product_id] = prod.cp_id
        pack
      end
    end
    packs.flatten!(1)

    Util::Package.find_latest_packages packs
  end

  def get_distribution(id)
    distribution = self.products.collect do |prod|
      prod.get_distribution(self, id)
    end
    distribution.flatten(1)
  end

  def add_to_default_capsule
    CapsuleContent.default_capsule.try(:add_lifecycle_environment, self)
  end

  def unset_users_with_default
    users = ::User.with_default_environment(self.id)
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
      self.repositories.map(&:minor).compact.uniq.sort
    else
      self.organization.redhat_provider.available_releases
    end
  end

  def delete_core_environments
    # For each content view associated with this lifecycle environment, there may be
    # a puppet environment (in the core/Foreman), so let's delete those
    self.content_views.each do |content_view|
      if foreman_env = Environment.find_by_katello_id(self.organization, self, content_view)
        foreman_env.destroy
      end
    end
  end

  def delete_default_view_version
    self.default_content_view_version.destroy if library?
  end

  private

  def self.humanize_class_name
   _("Lifecycle Environment")
  end

end
end
