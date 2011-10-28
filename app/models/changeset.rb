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

class NotInLockerValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:environment] << _("Locker environment can have no changeset!") if record.environment.locker?
  end
end

class Changeset < ActiveRecord::Base
  include Authorization
  include AsyncOrchestration

  NEW = 'new'
  REVIEW = 'review'
  PROMOTED = 'promoted'
  PROMOTING = 'promoting'
  STATES = [NEW, REVIEW, PROMOTING, PROMOTED]


  validates_inclusion_of :state,
    :in => STATES,
    :allow_blank => false,
    :message => "A changeset must have one of the following states: #{STATES.join(', ')}."

  validates :name, :presence => true, :allow_blank => false
  validates_uniqueness_of :name, :scope => :environment_id, :message => N_("Must be unique within an environment")
  validates :environment, :presence=>true
  validates_with NotInLockerValidator
  has_and_belongs_to_many :products, :uniq => true
  has_many :packages, :class_name=>"ChangesetPackage", :inverse_of=>:changeset
  has_many :users, :class_name=>"ChangesetUser", :inverse_of=>:changeset
  has_and_belongs_to_many :system_templates
  has_many :errata, :class_name=>"ChangesetErratum", :inverse_of=>:changeset
  has_many :repos, :class_name=>"ChangesetRepo", :inverse_of => :changeset
  has_many :distributions, :class_name=>"ChangesetDistribution", :inverse_of => :changeset
  has_many :dependencies, :class_name=>"ChangesetDependency", :inverse_of =>:changeset
  belongs_to :environment, :class_name=>"KTEnvironment"
  belongs_to :task_status
  before_save :uniquify_artifacts

  scoped_search :on => :name, :complete_value => true, :rename => :'changeset.name'
  scoped_search :on => :created_at, :complete_value => true, :rename => :'changeset.create_date'
  scoped_search :on => :promotion_date, :complete_value => true, :rename => :'changeset.promotion_date'
  scoped_search :in => :products, :on => :name, :complete_value => true, :rename => :'custom_product.name'
  scoped_search :in => :products, :on => :description, :complete_value => true, :rename => :'custom_product.description'

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
    to_ret = to_ret + self.repos.collect{|pkg| pkg.product}
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

    if async
      self.state = Changeset::PROMOTING
      self.save!
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

  def add_product product_name
    product = find_product(product_name)
    self.products << product
    product
  end

  def add_template template_name
    tpl = find_template(template_name)
    self.system_templates << tpl
    tpl
  end

  def add_package package_name, product_name
    product = find_product(product_name)
    product.repos(self.environment.prior).each do |repo|
      #search for package in all repos in a product
      idx = repo.packages.index do |p| p.name == package_name end
      if idx != nil
        pack = repo.packages[idx]
        cs_pack = ChangesetPackage.new(:package_id => pack.id, :display_name => package_name, :product_id => product.id, :changeset => self)
        cs_pack.save!
        self.packages << cs_pack

        return cs_pack
      end
    end
    raise Errors::ChangesetContentException.new("Package not found in the source environment.")
  end

  def add_erratum erratum_id, product_name
    product = find_product(product_name)
    product.repos(self.environment.prior).each do |repo|
      #search for erratum in all repos in a product
      idx = repo.errata.index do |e| e.id == erratum_id end
      if idx != nil
        erratum = repo.errata[idx]
        cs_erratum = ChangesetErratum.new(:errata_id => erratum.id, :display_name => erratum_id, :product_id => product.id, :changeset => self)
        cs_erratum.save!
        self.errata << cs_erratum

        return cs_erratum
      end
    end
    raise Errors::ChangesetContentException.new("Erratum not found in the source environment.")
  end

  def add_repo repo_name, product_name
    product = find_product(product_name)
    repos = product.repos(self.environment.prior)
    idx = repos.index do |r| r.name == repo_name end
    if idx != nil
      repo = repos[idx]
      cs_repo = ChangesetRepo.new(:repo_id => repo.id, :display_name => repo_name, :product_id => product.id, :changeset => self)
      cs_repo.save!
      self.repos << cs_repo

      return cs_repo
    end
    raise Errors::ChangesetContentException.new("Repository not found within this environment.")
  end

  def add_distribution distribution_id, product_name
    product = find_product(product_name)
    repos = product.repos(self.environment)
    idx = nil
    repos.each do |repo|
      idx = repo.distributions.index do |d| d.id == distribution_id end
    end
    if idx != nil
      self.distributions << ChangesetDistribution.new(:distribution_id => distribution_id,
                                                      :display_name => distribution_id,
                                                      :product_id => product.id,
                                                      :changeset => self)
      return
    end
    raise Errors::ChangesetContentException.new("Distribution not found within this environment.")
  end


  def remove_product product_name
    prod = self.products.find_by_name(product_name)
    raise Errors::ChangesetContentException.new("Product #{product_name} not found in the changeset.") if prod.nil?
    self.products.delete(prod)
  end

  def remove_template template_name
    tpl = self.system_templates.find_by_name(template_name)
    raise Errors::ChangesetContentException.new("Template #{template_name} not found in the changeset.") if tpl.nil?
    self.system_templates.delete(tpl)
  end

  def remove_package package_name, product_name
    product = find_product(product_name)
    product.repos(self.environment.prior).each do |repo|
      #search for package in all repos in a product
      idx = repo.packages.index do |p| p.name == package_name end
      if idx != nil
        pack = repo.packages[idx]
        ChangesetPackage.destroy_all(:package_id => pack.id, :changeset_id => self.id, :product_id => product.id)
        return
     end
    end
  end

  def remove_erratum erratum_id, product_name
    product = find_product(product_name)
    product.repos(self.environment.prior).each do |repo|
      #search for erratum in all repos in a product
      idx = repo.errata.index do |e| e.id == erratum_id end
      if idx != nil
        erratum = repo.errata[idx]
        ChangesetErratum.destroy_all(:errata_id => erratum.id, :changeset_id => self.id, :product_id => product.id)
        return
      end
    end
  end

  def remove_repo repo_name, product_name
    product = find_product(product_name)
    repos = product.repos(self.environment.prior)
    idx = repos.index do |r| r.name == repo_name end
    if idx != nil
      repo = repos[idx]
      ChangesetRepo.destroy_all(:repo_id => repo.id, :changeset_id => self.id, :product_id => product.id)
      return
    end
  end


  def remove_distribution distribution_id, product_name
    product = find_product(product_name)
    repos = product.repos(self.environment)
    idx = nil
    repos.each do |repo|
      idx = repo.distributions.index do |d| d.id == distribution_id end
    end
    if idx != nil
      ChangesetDistribution.destroy_all(:distribution_id => distribution_id, :changeset_id => self.id, :product_id => product.id)
    end
  end

  private

  def find_template template_name
    from_env = self.environment.prior
    tpl = from_env.system_templates.find_by_name(template_name)
    raise Errors::ChangesetContentException.new("Template not found within environment you want to promote from.") if tpl.nil?
    tpl
  end

  def find_product product_name
    from_env = self.environment.prior
    product = from_env.products.find_by_name(product_name)
    raise Errors::ChangesetContentException.new("Product not found within environment you want to promote from.") if product.nil?
    product
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
    update_progress! '80'
    promote_packages from_env, to_env
    update_progress! '90'
    promote_errata   from_env, to_env
    update_progress! '95'
    promote_distributions from_env, to_env
    update_progress! '100'
    self.promotion_date = Time.now
    self.state = Changeset::PROMOTED
    self.save!
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

    for r in self.repos
      product = r.product
      repo    = Repository.find_by_pulp_id(r.repo_id)

      next if (products.uniq! or []).include? product

      cloned = repo.get_clone(to_env)
      if cloned
        async_tasks << cloned.sync
      else
        async_tasks << repo.promote(to_env, product)
      end
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
        clone = repo.get_clone to_env

        if (repo.has_package? pkg.package_id) and (!clone.has_package? pkg.package_id)
          pkgs_promote[clone] ||= []
          pkgs_promote[clone] << pkg.package_id
        end
      end
    end

    pkgs_promote.each_pair do |repo, pkgs|
      repo.add_packages(pkgs)
    end
  end


  def promote_errata from_env, to_env
    #repo->list of errata_ids
    errata_promote = {}

    not_included_errata.each do |err|
      product = err.product

      product.repos(from_env).each do |repo|
        clone = repo.get_clone to_env

        if (repo.has_erratum? err.errata_id) and (!clone.has_erratum? err.errata_id)
          errata_promote[clone] ||= []
          errata_promote[clone] << err.errata_id
        end
      end
    end

    errata_promote.each_pair do |repo, errata|
      repo.add_errata(errata)
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

        if (repo.has_distribution? distro.distribution_id) and (!clone.has_distribution? distro.distribution_id)
          distribution_promote[clone] = distro.distribution_id
        end
      end
    end

    distribution_promote.each_pair do |repo, distro|
      repo.add_distribution(distro)
    end

  end


  def uniquify_artifacts
    system_templates.uniq! unless self.system_templates.nil?
    products.uniq! unless self.products.nil?
    [[:packages,:package_id],[:errata, :errata_id],[:repos, :repo_id],[:distributions, :distribution_id]].each do |items, item_id|
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
    product_repos = product.repos(environment)
    product_repos.delete_if do |product_repo|
      not repos.index{ |cs_repo| cs_repo.repo_id == product_repo.id }.nil?
    end
    product_repos
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
    return [] if package_names.empty?

    from_repos = not_included_repos(product, from_env).map{ |r| r.id }

    dependencies = Pulp::Package.dep_solve(package_names, from_repos)
    dependencies
  end

  def build_dependencies product, dependencies
    new_dependencies = []

    dependencies.each_pair do |package_name, dep_packages|
      dep_packages.each do |dep_package|
        new_dependencies << ChangesetDependency.new(:package_id => dep_package['id'],
                                                    :display_name => dep_package['name'],
                                                    :product_id => product.id,
                                                    :dependency_of => package_name,
                                                    :changeset => self)
      end
    end
    new_dependencies
  end

end
