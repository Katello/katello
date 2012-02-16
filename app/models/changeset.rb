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
    record.errors[:environment] << _("Library environment cannot contain a changeset!") if record.environment.library?
  end
end

require 'util/notices'
require 'util/package_util'

class Changeset < ActiveRecord::Base
  include Authorization
  include AsyncOrchestration
  include Katello::Notices

  include IndexedModel
  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :description, :package, :errata, :product, :repo, :system_template, :user]

  mapping do
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end

  NEW = 'new'
  REVIEW = 'review'
  PROMOTED = 'promoted'
  PROMOTING = 'promoting'
  FAILED = 'failed'
  STATES = [NEW, REVIEW, PROMOTING, PROMOTED, FAILED]


  validates_inclusion_of :state,
    :in => STATES,
    :allow_blank => false,
    :message => "A changeset must have one of the following states: #{STATES.join(', ')}."

  validates :name, :presence => true, :allow_blank => false, :length => { :maximum => 255 }
  validates_uniqueness_of :name, :scope => :environment_id, :message => N_("Must be unique within an environment")
  validates :environment, :presence=>true
  validates :description, :katello_description_format => true
  validates_with NotInLibraryValidator
  has_and_belongs_to_many :products, :uniq => true
  has_many :packages, :class_name=>"ChangesetPackage", :inverse_of=>:changeset
  has_many :users, :class_name=>"ChangesetUser", :inverse_of=>:changeset
  has_and_belongs_to_many :system_templates, :uniq => true
  has_many :errata, :class_name=>"ChangesetErratum", :inverse_of=>:changeset
  has_and_belongs_to_many :repos, :class_name=>"Repository", :uniq => true
  has_many :distributions, :class_name=>"ChangesetDistribution", :inverse_of => :changeset
  has_many :dependencies, :class_name=>"ChangesetDependency", :inverse_of =>:changeset
  belongs_to :environment, :class_name=>"KTEnvironment"
  belongs_to :task_status
  before_save :uniquify_artifacts

  def key_for item
    "changeset_#{id}_#{item}"
  end

  def package_ids
    packages.collect{|pack| pack.package_id}
  end

  def errata_ids
    errata.collect{|erratum| erratum.errata_id}
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
    to_ret = to_ret + self.packages.collect{|pkg| pkg.product}
    to_ret = to_ret + self.errata.collect{|pkg| pkg.product}
    to_ret = to_ret + self.repos.collect{|rep| rep.product}
    to_ret = to_ret + self.distributions.collect{|distro| distro.product}
    to_ret.uniq
  end


  def calc_dependencies
    all_dependencies = []
    not_included_products.each do |product|
      dependencies = calc_dependencies_for_product product
      all_dependencies += build_dependencies(product, dependencies)
    end
    all_dependencies
  end

  def calc_and_save_dependencies
    self.dependencies = self.calc_dependencies
    self.save()
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end


  def promote async=true
    raise _("Cannot promote the changset '#{self.name}' because it is not in the review phase.") if self.state != Changeset::REVIEW
    #check for other changesets promoting
    raise _("Cannot promote the changeset '#{self.name}' while another changeset (#{self.environment.promoting.first.name}) is being promoted.") if self.environment.promoting_to?

    self.state = Changeset::PROMOTING
    self.save!

    if async
      task = self.async(:organization=>self.environment.organization).promote_content
      self.task_status = task
      self.save!
      self.task_status
    else
      self.task_status = nil
      self.save!
      promote_content
    end
  end

  def add_product cpid
    product = find_product_by_cpid(cpid)
    raise _("Product '#{product.name}' hasn't any repositories") if product.repos(self.environment.prior).empty?
    self.products << product
    product
  end

  def add_template template_id
    tpl = find_template(template_id)
    self.system_templates << tpl
    tpl
  end

  def add_package package_name, product_cpid
    product = find_product_by_cpid(product_cpid)
    pack = find_package product, package_name
    display_name = Katello::PackageUtils::build_nvrea(pack, false)
    cs_pack = ChangesetPackage.new(:package_id => pack["id"], :display_name => display_name, :product_id => product.id, :changeset => self)
    cs_pack.save!
    self.packages << cs_pack
  end

  def add_erratum erratum_id, product_cpid
    product = find_product_by_cpid(product_cpid)
    cs_erratum = ChangesetErratum.new(:errata_id => erratum_id, :display_name => erratum_id, :product_id => product.id, :changeset => self)
    cs_erratum.save!
    self.errata << cs_erratum
  end

  def add_repo repo_id, product_cpid
    repo = find_repo(repo_id, product_cpid)
    raise Errors::ChangesetContentException.new("Repository not found within this environment.") unless repo
    self.repos << repo
    repo
  end

  def add_distribution distribution_id, product_cpid
    product = find_product_by_cpid(product_cpid)
    distro = ChangesetDistribution.new(:distribution_id => distribution_id,
                                       :display_name => distribution_id,
                                       :product_id => product.id,
                                       :changeset => self)
    distro.save!
    self.distributions << distro
  end

  def remove_product cpid
    prod = self.products.find_by_cp_id(cpid)
    raise Errors::ChangesetContentException.new("Product #{cpid} not found in the changeset.") if prod.nil?
    self.products.delete(prod)
  end

  def remove_template template_id
    tpl = self.system_templates.find(template_id)
    raise Errors::ChangesetContentException.new("Template #{template_id} not found in the changeset.") if tpl.nil?
    self.system_templates.delete(tpl)
  end

  def remove_package package_nvre, product_cpid
    product = find_product_by_cpid(product_cpid)
    pack = find_package_by_nvre product, package_nvre
    ChangesetPackage.destroy_all(:package_id => pack["id"], :changeset_id => self.id, :product_id => product.id)
  end

  def remove_erratum erratum_id, product_cpid
    product = find_product_by_cpid(product_cpid)
    ChangesetErratum.destroy_all(:errata_id => erratum_id, :changeset_id => self.id, :product_id => product.id)
  end

  def remove_repo repo_id, product_cpid
    repo = find_repo(repo_id, product_cpid)
    self.repos.delete(repo) if repo
  end

  def remove_distribution distribution_id, product_cpid
    product = find_product_by_cpid(product_cpid)
    ChangesetDistribution.destroy_all(:distribution_id => distribution_id, :changeset_id => self.id, :product_id => product.id)
  end

  private

  def find_template template_id
    from_env = self.environment.prior
    tpl = from_env.system_templates.find(template_id)
    raise Errors::ChangesetContentException.new("Template not found within environment you want to promote from.") if tpl.nil?
    tpl
  end

  def find_product product_name
    from_env = self.environment.prior
    product = from_env.products.find_by_name(product_name)
    raise Errors::ChangesetContentException.new("Product not found within environment you want to promote from.") if product.nil?
    product
  end

  def find_product_by_cpid product_cpid
    from_env = self.environment.prior
    product = from_env.products.find_by_cp_id(product_cpid.to_s)
    raise Errors::ChangesetContentException.new("Product not found within environment you want to promote from.") if product.nil?
    product
  end

  def find_package product, name_or_nvre
    package_data = Katello::PackageUtils::parse_nvrea_nvre(name_or_nvre)
    if not package_data.nil?
      packs = product.find_packages_by_nvre(self.environment.prior, package_data[:name], package_data[:version], package_data[:release], package_data[:epoch])
    else
      packs = product.find_packages_by_name(self.environment.prior, name_or_nvre)
      packs = Katello::PackageUtils::find_latest_packages(packs)
    end
    raise Errors::ChangesetContentException.new(_("Package '#{name_or_nvre}' was not found in the source environment.")) if packs.empty?
    packs[0].with_indifferent_access
  end

  def find_package_by_nvre product, nvre
    package_data = Katello::PackageUtils::parse_nvrea_nvre(nvre)
    raise Errors::ChangesetContentException.new(_("Package has to be specified by its nvre.")) if package_data.nil?

    packs = product.find_packages_by_nvre(self.environment.prior, package_data[:name], package_data[:version], package_data[:release], package_data[:epoch])
    raise Errors::ChangesetContentException.new(_("Package '#{nvre}' was not found in the source environment.")) if packs.empty?
    packs[0].with_indifferent_access
  end

  def update_progress! percent
    if self.task_status
      self.task_status.progress = percent
      self.task_status.save!
    end
  end


  def promote_content
    update_progress! '0'
    self.calc_and_save_dependencies

    update_progress! '10'

    from_env = self.environment.prior
    to_env   = self.environment

    PulpTaskStatus::wait_for_tasks promote_products(from_env, to_env)
    update_progress! '30'
    PulpTaskStatus::wait_for_tasks promote_templates(from_env, to_env)
    update_progress! '50'
    PulpTaskStatus::wait_for_tasks promote_repos(from_env, to_env)
    update_progress! '70'
    to_env.update_cp_content
    update_progress! '80'
    promote_packages from_env, to_env
    update_progress! '90'
    promote_errata   from_env, to_env
    update_progress! '95'
    promote_distributions from_env, to_env
    update_progress! '100'

    generate_metadata from_env, to_env

    self.promotion_date = Time.now
    self.state = Changeset::PROMOTED
    self.save!

    index_repo_content to_env

    message = _("Successfully promoted changeset '%s'.") % self.name
    notice message, {:synchronous_request => false, :request_type => "changesets___promote"}

  rescue Exception => e

    self.state = Changeset::FAILED
    self.save!
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    details = e.message
    error_text = _("Failed to promote changeset '%s'. Check notices for more details") % self.name
    notice error_text, {:details =>details, :level => :error, :synchronous_request => false, :request_type => "changesets___promote"}

    index_repo_content to_env

    raise e
  end


  def promote_templates from_env, to_env
    async_tasks = self.system_templates.collect do |tpl|
      tpl.promote from_env, to_env
    end
    async_tasks.flatten(1)
  end


  def promote_products from_env, to_env
    async_tasks = self.products.collect do |product|
      product.promote from_env, to_env
    end
    async_tasks.flatten(1)
  end


  def promote_repos from_env, to_env
    async_tasks = []
    self.repos.each do |repo|
      product = repo.product
      next if (products.uniq! or []).include? product

      async_tasks << repo.promote(from_env, to_env)
    end
    async_tasks.flatten(1)
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


  def promote_packages from_env, to_env
    #repo->list of pkg_ids
    pkgs_promote = {}

    (not_included_packages + dependencies).each do |pkg|
      product = pkg.product

      product.repos(from_env).each do |repo|
        if repo.is_cloned_in? to_env
          clone = repo.get_clone to_env

          if (repo.has_package? pkg.package_id) and (!clone.has_package? pkg.package_id)
            pkgs_promote[clone] ||= []
            pkgs_promote[clone] << pkg.package_id
          end
        end
      end
    end

    pkgs_promote.each_pair do |repo, pkgs|
      repo.add_packages(pkgs)
      Glue::Pulp::Package.index_packages(pkgs)
    end
  end


  def promote_errata from_env, to_env
    #repo->list of errata_ids
    errata_promote = {}

    not_included_errata.each do |err|
      product = err.product

      product.repos(from_env).each do |repo|
        if repo.is_cloned_in? to_env
          clone = repo.get_clone to_env

          if (repo.has_erratum? err.errata_id) and (!clone.has_erratum? err.errata_id)
            errata_promote[clone] ||= []
            errata_promote[clone] << err.errata_id
          end
        end
      end
    end

    errata_promote.each_pair do |repo, errata|
      repo.add_errata(errata)
      Glue::Pulp::Errata.index_errata(errata)
    end
  end


  def promote_distributions from_env, to_env
    #repo->list of distribution_ids
    distribution_promote = {}

    for distro in self.distributions
      product = distro.product

      #skip distributions that have already been promoted with the products
      next if (products.uniq! or []).include? product

      product.repos(from_env).each do |repo|
        clone = repo.get_clone to_env
        next if clone.nil?

        if (repo.has_distribution? distro.distribution_id) and (!clone.has_distribution? distro.distribution_id)
          distribution_promote[clone] = distro.distribution_id
        end
      end
    end

    distribution_promote.each_pair do |repo, distro|
      repo.add_distribution(distro)
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

  def generate_metadata from_env, to_env
    affected_repos.each do |repo|
        repo.get_clone(to_env).generate_metadata
    end
  end

  def uniquify_artifacts
    system_templates.uniq! unless self.system_templates.nil?
    products.uniq! unless self.products.nil?
    [[:packages,:package_id],[:errata, :errata_id],[:distributions, :distribution_id]].each do |items, item_id|
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

  def not_included_products
    products_ids = []
    products_ids += self.packages.map { |p| p.product.cp_id }
    products_ids += self.errata.map { |e| e.product.cp_id }
    products_ids -= self.products.collect{ |p| p.cp_id }
    products_ids.uniq.collect do |product_cp_id|
      Product.find_by_cp_id(product_cp_id)
    end
  end

  def not_included_repos product, environment
    product_repos = product.repos(environment) - self.repos
  end


  def errata_for_dep_calc product
    cs_errata = ChangesetErratum.where({:changeset_id=>self.id, :product_id=>product.id})
    cs_errata.collect do |err|
      Glue::Pulp::Errata.find(err.errata_id)
    end
  end


  def packages_for_dep_calc product
    packages = []

    cs_pacakges = ChangesetPackage.where({:changeset_id=>self.id, :product_id=>product.id})
    packages += cs_pacakges.collect do |pack|
      Glue::Pulp::Package.find(pack.package_id)
    end

    packages += errata_for_dep_calc(product).collect do |err|
      err.included_packages
    end.flatten(1)

    packages
  end


  def calc_dependencies_for_product product
    from_env = self.environment.prior
    to_env   = self.environment

    package_names = packages_for_dep_calc(product).map{ |p| p.name }.uniq
    return {} if package_names.empty?

    from_repos = not_included_repos(product, from_env)
    to_repos = product.repos(to_env)

    dependencies = calc_dependencies_for_packages package_names, from_repos, to_repos
    dependencies
  end

  def calc_dependencies_for_packages package_names, from_repos, to_repos
    all_deps = []
    deps = []
    to_resolve = package_names
    while not to_resolve.empty?
      all_deps += deps

      deps = get_promotable_dependencies_for_packages to_resolve, from_repos, to_repos
      deps = Katello::PackageUtils::filter_latest_packages_by_name deps

      to_resolve = deps.map{ |d| d['provides'] }.flatten(1).uniq - all_deps.map{ |d| d['provides'] }.flatten(1) - package_names
    end
    all_deps
  end

  def get_promotable_dependencies_for_packages package_names, from_repos, to_repos
    from_repo_ids = from_repos.map{ |r| r.pulp_id }
    @next_env_pkg_ids ||= package_ids(to_repos)

    resolved_deps = Pulp::Package.dep_solve(package_names, from_repo_ids)['resolved']
    resolved_deps = resolved_deps.values.flatten(1)
    resolved_deps = resolved_deps.reject {|dep| not @next_env_pkg_ids.index(dep['id']).nil? }
    resolved_deps
  end

  def package_ids repos
    pkg_ids = []
    repos.each do |repo|
      pkg_ids += repo.packages.collect { |pkg| pkg.id }
    end
    pkg_ids
  end

  def build_dependencies product, dependencies
    new_dependencies = []

    dependencies.each do |dep|
        new_dependencies << ChangesetDependency.new(:package_id => dep['id'],
                                                    :display_name => dep['filename'],
                                                    :product_id => product.id,
                                                    :dependency_of => '???',
                                                    :changeset => self)
    end
    new_dependencies
  end

  def find_repo repo_id, product_cpid
    product = find_product_by_cpid(product_cpid)
    product.repos(self.environment.prior).where("repositories.id" => repo_id).first
  end

  def affected_repos
    repos = []
    repos += self.packages.collect{ |e| e.promotable_repositories }.flatten(1)
    repos += self.errata.collect{ |p| p.promotable_repositories }.flatten(1)
    repos += self.distributions.collect{ |d| d.promotable_repositories }.flatten(1)

    repos.uniq
  end

  def extended_index_attrs
    pkgs = self.packages.collect{|pkg| pkg.display_name}
    errata = self.errata.collect{|err| err.display_name}
    products = self.products.collect{|prod| prod.name}
    repos = self.repos.collect{|repo| repo.name}
    templates = self.system_templates.collect{|t| t.name}
    {
      :name_sort=> self.name.downcase,
      :package=>pkgs,
      :errata=>errata,
      :product=>products,
      :repo=>repos,
      :system_template=>templates,
      :user=> self.task_status.nil? ? "" : self.task_status.user.username
    }
  end

end
