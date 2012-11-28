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

class NotInLibraryValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:environment] << _("The '%s' environment cannot contain a changeset!") % "Library" if record.environment.library?
  end
end

require 'util/package_util'

class Changeset < ActiveRecord::Base
  include Authorization
  include AsyncOrchestration

  include IndexedModel
  index_options :extended_json => :extended_index_attrs,
                :display_attrs => [:name, :description, :package, :errata, :product, :repo, :system_template, :user, :type]

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end

  NEW       = 'new'
  REVIEW    = 'review'
  PROMOTED  = 'promoted'
  PROMOTING = 'promoting'
  DELETING = 'deleting'
  DELETED  = 'deleted'
  FAILED    = 'failed'
  STATES    = [NEW, REVIEW, PROMOTING, PROMOTED, FAILED, DELETING, DELETED]


  PROMOTION = 'promotion'
  DELETION  = 'deletion'
  TYPES     = [PROMOTION, DELETION]

  validates_inclusion_of :state,
                         :in          => STATES,
                         :allow_blank => false,
                         :message     => "A changeset must have one of the following states: #{STATES.join(', ')}."

  validates :name, :presence => true, :allow_blank => false, :length => { :maximum => 255 }
  validates_uniqueness_of :name, :scope => :environment_id, :message => N_("Must be unique within an environment")
  validates :environment, :presence => true
  validates :description, :katello_description_format => true
  validates_with NotInLibraryValidator

  has_and_belongs_to_many :products, :uniq => true
  has_many :packages, :class_name => "ChangesetPackage", :inverse_of => :changeset
  has_many :users, :class_name => "ChangesetUser", :inverse_of => :changeset
  has_and_belongs_to_many :system_templates, :uniq => true
  has_many :errata, :class_name => "ChangesetErratum", :inverse_of => :changeset
  has_and_belongs_to_many :repos, :class_name => "Repository", :uniq => true
  has_many :distributions, :class_name => "ChangesetDistribution", :inverse_of => :changeset
  has_many :dependencies, :class_name => "ChangesetDependency", :inverse_of => :changeset
  belongs_to :environment, :class_name => "KTEnvironment"
  belongs_to :task_status

  before_save :uniquify_artifacts
  def key_for item
    "changeset_#{id}_#{item}"
  end

  def errata_ids
    errata.collect { |erratum| erratum.errata_id }
  end

  #get a list of all the products involved in the changeset
  #  but not necessarily 'in' the changeset
  def involved_products
    to_ret = self.products.clone #get a copy
    to_ret = to_ret + self.partial_products
    to_ret.uniq
  end

  def partial_products
    to_ret = []
    to_ret = to_ret + self.packages.collect { |pkg| pkg.product }
    to_ret = to_ret + self.errata.collect { |pkg| pkg.product }
    to_ret = to_ret + self.repos.collect { |rep| rep.product }
    to_ret = to_ret + self.distributions.collect { |distro| distro.product }
    to_ret.uniq
  end


  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def action_type
    return PROMOTION if PromotionChangeset === self
    DELETION
  end

  def deletion?
    self.class == DeletionChangeset
  end

  def promotion?
    self.class == PromotionChangeset
  end

  def self.create_for( acct_type, options)
    if PROMOTION == acct_type
      PromotionChangeset.create!(options)
    else
      DeletionChangeset.create!(options)
    end
  end

  def add_product! product

     env_to_verify_on_add_content.products.include? product or
         raise Errors::ChangesetContentException.new("Product not found within environment you want to promote from.")

     self.products << product
     save!
     product
   end

   def add_template! template
     env_to_verify_on_add_content.system_templates.include? template or
         raise Errors::ChangesetContentException.new("Template not found within environment you want to promote from.")

     self.system_templates << template # updates foreign key immediately
     save!
     return template
   end

   def add_package! name_or_nvre, product
     env_to_verify_on_add_content.products.include? product or
         raise Errors::ChangesetContentException.new(
                   "Package's product not found within environment you want to promote from.")

     package_data = find_package_data(product, name_or_nvre) or
         raise Errors::ChangesetContentException.new(
                   _("Package '%s' was not found in the source environment.") % name_or_nvre)

     nvrea = Katello::PackageUtils::build_nvrea(package_data, false)
     self.packages << package =
         ChangesetPackage.create!(:package_id => package_data["id"], :display_name => nvrea,
                                  :product_id => product.id, :changeset => self, :nvrea => nvrea)
     save!
     return package
   end

   def add_erratum! erratum_id, product
     product.has_erratum?(env_to_verify_on_add_content, erratum_id) or
         raise Errors::ChangesetContentException.new(
                   "Erratum not found within this environment you want to promote from.")

     self.errata << erratum =
         ChangesetErratum.create!(:errata_id  => erratum_id, :display_name => erratum_id,
                                  :product_id => product.id, :changeset => self)
     save!
     return erratum
   end

   def add_repository! repository
     env_to_verify_on_add_content.repositories.include? repository or
         raise Errors::ChangesetContentException.new(
                   "Repository not found within this environment you want to promote from.")

     self.repos << repository
     save!
     return repository
   end

   def add_distribution! distribution_id, product
     env_to_verify_on_add_content.repositories.any? { |repo| repo.has_distribution? distribution_id } or
         raise Errors::ChangesetContentException.new(
                   "Distribution not found within this environment you want to promote from.")

     distro = ChangesetDistribution.create!(:distribution_id => distribution_id,
                                       :display_name    => distribution_id,
                                       :product_id      => product.id,
                                       :changeset       => self)
     self.distributions << distro
     save!
     distro
   end

  def remove_product! product
    deleted = self.products.delete(product)
    save!
    return deleted
  end

  def remove_template! template
    deleted = self.system_templates.delete(template)
    save!
    return deleted
  end

  def remove_package! nvrea, product
    deleted = ChangesetPackage.destroy_all(:nvrea => nvrea, :changeset_id => self.id,
                                           :product_id => product.id)
    save!
    return deleted
  end

  def remove_erratum! erratum_id, product
    deleted = ChangesetErratum.destroy_all(:errata_id  => erratum_id, :changeset_id => self.id,
                                           :product_id => product.id)
    save!
    return deleted
  end

  def remove_repository! repository
    deleted = self.repos.delete(repository)
    save!
    return deleted
  end

  def remove_distribution! distribution_id, product
    deleted = ChangesetDistribution.destroy_all(:distribution_id => distribution_id,
                                                :changeset_id    => self.id, :product_id => product.id)
    save!
    return deleted
  end

  def as_json(options = nil)
    options ||= {}
    super(options.merge({
          :methods => [:action_type]
          })
       )
  end

  protected

  def validate_content! elements
    elements.each { |e| raise ActiveRecord::RecordInvalid.new(e) if not e.valid? }
  end

  def find_package_data(product, name_or_nvre)
    package_data = Katello::PackageUtils.parse_nvrea_nvre(name_or_nvre)

    if package_data
      packs = product.find_packages_by_nvre(env_to_verify_on_add_content,
                                             package_data[:name], package_data[:version],
                                             package_data[:release], package_data[:epoch])
    end

    if packs.blank? || !package_data
       packs = Katello::PackageUtils::find_latest_packages(
                  product.find_packages_by_name(env_to_verify_on_add_content, name_or_nvre))
    end

    packs.first.try(:with_indifferent_access)
  end

  def env_to_verify_on_add_content
    if promotion?
      self.environment.prior
    else
      self.environment
    end
  end

  def update_progress! percent
    if self.task_status
      self.task_status.progress = percent
      self.task_status.save!
    end
  end

  def index_repo_content to_env
    # for any repos contained within the changeset, index the packages & errata that have
    # been promoted to the next environment
    self.products.each do |product|
      product.repos(to_env).each do |repo|
        repo.index_packages
        repo.index_errata
      end
    end

    # during promotion of the repos, information like clone_id are updated... in order to have
    # that information available, reload the repos
    self.repos.reload

    self.repos.each do |repo|
      if repo.is_cloned_in? to_env
        clone = repo.get_clone(to_env)
        clone.index_packages
        clone.index_errata
      end
    end
  end

  def uniquify_artifacts
    system_templates.uniq! unless self.system_templates.nil?
    products.uniq! unless self.products.nil?
    [[:packages, :package_id], [:errata, :errata_id], [:distributions, :distribution_id]].each do |items, item_id|
      unless self.send(items).nil?
        s = Set.new
        # for some reason uniq! with a closure didn''t work
        # so invented an equivalent
        self.send(items).reject! do |item|
          includes = s.include? item.send(item_id)
          s.add(item.send(item_id)) unless includes
          includes
        end
      end
    end
  end

  def find_repo repo_id, product_cpid
    product = find_product_by_cpid(product_cpid)
    product.repos(self.environment.prior).where("repositories.id" => repo_id).first
  end


  def not_included_products
    products_ids = []
    products_ids += self.packages.map { |p| p.product.cp_id }
    products_ids += self.errata.map { |e| e.product.cp_id }
    products_ids -= self.products.collect { |p| p.cp_id }
    products_ids.uniq.collect do |product_cp_id|
      Product.find_by_cp_id(product_cp_id)
    end
  end

  def not_included_repos product, environment
    product_repos = product.repos(environment) - self.repos
  end


  def not_included_packages
    self.packages.delete_if do |pack|
      (products.uniq! or []).include? pack.product
    end
  end

  def not_included_errata
    self.errata.delete_if do |err|
      (products.uniq! or []).include? err.product
    end
  end

  def not_included_distribution
    self.distributions.delete_if do |distro|
      (products.uniq! or []).include? distro.product
    end
  end
  def extended_index_attrs
    type      = self.type == "PromotionChangeset" ? Changeset::PROMOTION : Changeset::DELETION
    pkgs      = self.packages.collect { |pkg| pkg.display_name }
    errata    = self.errata.collect { |err| err.display_name }
    products  = self.products.collect { |prod| prod.name }
    repos     = self.repos.collect { |repo| repo.name }
    templates = self.system_templates.collect { |t| t.name }
    { :name_sort       => self.name.downcase,
      :type            => type,
      :package         => pkgs,
      :errata          => errata,
      :product         => products,
      :repo            => repos,
      :system_template => templates,
      :user            => self.task_status.nil? ? "" : self.task_status.user.username
    }
  end

end

