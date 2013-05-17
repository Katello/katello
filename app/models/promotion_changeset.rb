#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.



class PromotionChangeset < Changeset
  use_index_of Changeset

  def apply(options = { })
    options = { :async => true, :notify => false }.merge options

    self.state == Changeset::REVIEW or
        raise _("Cannot promote the changeset '%s' because it is not in the review phase.") % self.name

    # check that solitare repos in the changeset will have its associated
    # product in the env as well after promotion
    repos_to_be_promoted.each do |repo|
      if not self.environment.products.to_a.include? repo.product and not products_to_be_promoted.include? repo.product
        raise _("Please add '%{product}' product to the changeset '%{changeset}' if you wish to promote repository '%{repo}' with it.") % {:product => repo.product.name, :changeset => self.name, :repo => repo.name}
      end
    end

    # if the user is attempting to promote a composite view and one or more of the
    # component views neither exists in the target environment nor is part
    # of the changeset, stop the promotion
    self.content_views.composite.each do |view|
      components = view.components_not_in_env(self.environment) - self.content_views
      unless components.blank?
        raise _("Please add '%{component_content_views}' to the changeset '%{changeset}' "\
                "if you wish to promote the composite view '%{composite_view}' with it.") %
                { :component_content_views => components.map(&:name).join(', '),
                  :changeset => self.name, :composite_view => view.name}
      end
    end

    validate_content! self.errata
    validate_content! self.packages
    validate_content! self.distributions
    validate_content! self.content_views

    # check no collision exists
    if (collision = Changeset.started.colliding(self).first)
      raise _("Cannot promote the changeset '%{changeset}' while another colliding changeset (%{another_changeset}) is being promoted.") %
                { :changeset => self.name, :another_changeset => collision.name }
    else
      self.state = Changeset::PROMOTING
      self.save!
    end

    if options[:async]
      task             = self.async(:organization => self.environment.organization).promote_content(options[:notify])
      self.task_status = task
      self.save!
      self.task_status
    else
      self.task_status = nil
      self.save!
      promote_content(options[:notify])
    end
  end

  def promote_content(notify = false)
    update_progress! '0'

    from_env = self.environment.prior
    to_env   = self.environment

    PulpTaskStatus::wait_for_tasks promote_products(from_env, to_env)
    update_progress! '40'
    PulpTaskStatus::wait_for_tasks promote_repos(from_env, to_env)
    update_progress! '60'
    to_env.content_view_environment.update_cp_content
    update_progress! '80'
    PulpTaskStatus::wait_for_tasks promote_views(from_env, to_env, self.content_views.composite(false))
    PulpTaskStatus::wait_for_tasks promote_views(from_env, to_env, self.content_views.composite(true))
    self.content_views.composite(false).each{|cv| cv.index_repositories(to_env)}
    self.content_views.composite(true).each{|cv| cv.index_repositories(to_env)}

    update_view_cp_content(to_env)
    update_progress! '85'
    promote_packages from_env, to_env
    update_progress! '90'
    promote_errata from_env, to_env
    update_progress! '95'
    promote_distributions from_env, to_env
    update_progress! '100'

    PulpTaskStatus::wait_for_tasks generate_metadata from_env, to_env

    self.promotion_date = Time.now
    self.state          = Changeset::PROMOTED

    Glue::Event.trigger(Katello::Actions::ChangesetPromote, self)

    self.save!

    index_repo_content to_env

    if notify
      message = _("Successfully promoted changeset '%s'.") % self.name
      Notify.success message, :request_type => "changesets___promote", :organization => self.environment.organization
    end

  rescue => e
    self.state = Changeset::FAILED
    self.save!
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    if notify
      Notify.exception _("Failed to promote changeset '%s'. Check notices for more details") % self.name, e,
                   :request_type => "changesets___promote", :organization => self.environment.organization
    end
    index_repo_content to_env
    raise e
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

  def promote_views(from_env, to_env, views)
    views.collect do |view|
      view.promote(from_env, to_env)
    end.flatten
  end

  def update_view_cp_content(to_env)
    self.content_views.collect do |view|
      view.update_cp_content(to_env)
    end
  end

  def promote_packages from_env, to_env
    #repo->list of pkg_ids
    pkgs_promote = { }

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
    pkg_ids = []

    pkgs_promote.each_pair do |repo, pkgs|
      repo.add_packages(pkgs)
      pkg_ids.concat(pkgs)
    end
    Package.index_packages(pkg_ids)
  end


  def promote_errata from_env, to_env
    #repo->list of errata_ids
    errata_promote = { }

    not_included_errata.each do |err|
      product = err.product

      product.repos(from_env).each do |repo|
        if repo.is_cloned_in? to_env
          clone             = repo.get_clone to_env


          if repo.has_erratum? err.errata_id and !clone.has_erratum? err.errata_id
            errata_promote[clone] ||= []
            errata_promote[clone] << err.errata_id
          end
        end
      end
    end

    errata_ids = []
    errata_promote.each_pair do |repo, errata|
      repo.add_errata(errata)
      errata_ids.concat(errata)
    end
    Errata.index_errata(errata_ids)
  end


  def promote_distributions from_env, to_env
    #repo->list of distribution_ids
    distribution_promote = { }

    for distro in self.distributions
      product = distro.product

      #skip distributions that have already been promoted with the products
      next if (products.uniq! or []).include? product

      product.repos(from_env).each do |repo|
        clone = repo.get_clone to_env
        next if clone.nil?

        if repo.has_distribution? distro.distribution_id and
            !clone.has_distribution? distro.distribution_id
          distribution_promote[clone] = distro.distribution_id
        end
      end
    end

    distribution_promote.each_pair do |repo, distro|
      repo.add_distribution(distro)
    end
  end

  def get_promotable_dependencies_for_packages package_names, from_repos, to_repos
    from_repo_ids     = from_repos.map { |r| r.pulp_id }
    @next_env_pkg_ids ||= package_ids(to_repos)

    resolved_deps = Resources::Pulp::Package.dep_solve(package_names, from_repo_ids)['resolved']
    resolved_deps = resolved_deps.values.flatten(1)
    resolved_deps = resolved_deps.reject { |dep| not @next_env_pkg_ids.index(dep['id']).nil? }
    resolved_deps
  end

  def repos_to_be_promoted
    repos = self.repos || []
    return repos.uniq
  end

  def products_to_be_promoted
    products = self.products || []
    return products.uniq
  end

  def calc_dependencies
    all_dependencies = []
    not_included_products.each do |product|
      dependencies     = calc_dependencies_for_product product
      all_dependencies += build_dependencies(product, dependencies)
    end
    all_dependencies
  end

  def calc_and_save_dependencies
    self.dependencies = self.calc_dependencies
    self.save()
  end

  def errata_for_dep_calc product
    cs_errata = ChangesetErratum.where({ :changeset_id => self.id, :product_id => product.id })
    cs_errata.collect do |err|
      Errata.find(err.errata_id)
    end
  end


  def packages_for_dep_calc product
    packages = []

    cs_pacakges = ChangesetPackage.where({ :changeset_id => self.id, :product_id => product.id })
    packages    += cs_pacakges.collect do |pack|
      Package.find(pack.package_id)
    end

    packages += errata_for_dep_calc(product).collect do |err|
      err.included_packages
    end.flatten(1)

    packages
  end


  def calc_dependencies_for_product product
    from_env = self.environment.prior
    to_env   = self.environment

    package_names = packages_for_dep_calc(product).map { |p| p.name }.uniq
    return { } if package_names.empty?

    from_repos = not_included_repos(product, from_env)
    to_repos   = product.repos(to_env)

    dependencies = calc_dependencies_for_packages package_names, from_repos, to_repos
    dependencies
  end

  def calc_dependencies_for_packages package_names, from_repos, to_repos
    all_deps   = []
    deps       = []
    to_resolve = package_names
    while not to_resolve.empty?
      all_deps += deps

      deps = get_promotable_dependencies_for_packages to_resolve, from_repos, to_repos
      deps = Util::Package::filter_latest_packages_by_name deps

      to_resolve = deps.map { |d| d['provides'] }.flatten(1).uniq -
          all_deps.map { |d| d['provides'] }.flatten(1) -
          package_names
    end
    all_deps
  end

  def build_dependencies product, dependencies
    new_dependencies = []

    dependencies.each do |dep|
      new_dependencies << ChangesetDependency.new(:package_id    => dep['id'],
                                                  :display_name  => dep['filename'],
                                                  :product_id    => product.id,
                                                  :dependency_of => '???',
                                                  :changeset     => self)
    end
    new_dependencies
  end

  def generate_metadata from_env, to_env
    async_tasks = affected_repos.collect do |repo|
      repo.get_clone(to_env).generate_metadata
    end
    async_tasks.flatten(1)
  end

  def affected_repos
    repos = []
    repos += self.packages.collect { |e| e.promotable_repositories }.flatten(1)
    repos += self.errata.collect { |p| p.promotable_repositories }.flatten(1)
    repos += self.distributions.collect { |d| d.promotable_repositories }.flatten(1)
    repos += self.repos_to_be_promoted
    repos += self.content_views.collect { |v| v.repos(self.environment.prior)}.flatten(1)
    repos += self.products_to_be_promoted.collect{|p| p.repos(self.environment.prior)}.flatten(1)
    repos.uniq
  end

  def package_ids repos
    pkg_ids = []
    repos.each do |repo|
      pkg_ids += repo.packages.collect { |pkg| pkg.id }
    end
    pkg_ids
  end

  def repos_to_be_promoted
    repos = self.repos || []
    return repos.uniq
  end

  def products_to_be_promoted
    products = self.products || []
    return products.uniq
  end
end
