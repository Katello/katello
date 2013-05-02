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


require 'set'
class DeletionChangeset < Changeset
  use_index_of Changeset if Katello.config.use_elasticsearch
  def apply(options = { })
    options = { :async => true, :notify => false }.merge options

    self.state == Changeset::REVIEW or
        raise _("Cannot delete the changeset '%s' because it is not in the review phase.") % self.name

    validate_content! self.errata
    validate_content! self.packages
    validate_content! self.distributions

    # check no collision exists
    if (collision = Changeset.started.colliding(self).first)
      raise _("Cannot promote the changeset '%{changeset}' while another colliding changeset (%{another_changeset}) is being promoted.") %
                { :changeset => self.name, :another_changeset => collision.name }
    else
      self.state = Changeset::DELETING
      self.save!
    end

    if options[:async]
      task  = self.async(:organization => self.environment.organization).delete_content(options[:notify])
      self.task_status = task
      self.save!
      self.task_status
    else
      self.task_status = nil
      self.save!
      delete_content(options[:notify])
    end
  end

  def delete_content(notify = false)
    update_progress! '0'
    update_progress! '10'
    from_env = self.environment

    @affected_repos = Set.new
    delete_products(from_env)
    update_progress! '30'
    update_progress! '50'
    delete_repos from_env
    update_progress! '60'
    delete_views from_env
    update_progress! '70'
    from_env.content_view_environment.update_cp_content
    update_progress! '80'
    delete_packages from_env
    update_progress! '90'
    delete_errata from_env
    update_progress! '95'
    delete_distributions from_env
    update_progress! '100'


    PulpTaskStatus::wait_for_tasks generate_metadata

    self.promotion_date = Time.now
    self.state          = Changeset::DELETED
    self.save!

    index_repo_content from_env

    if notify
      message = _("Successfully deleted changeset '%s'.") % self.name
      Notify.success message, :request_type => "changesets___delete", :organization => self.environment.organization
    end

  rescue => e
    self.state = Changeset::FAILED
    self.save!
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    if notify
      Notify.exception _("Failed to delete changeset '%s'. Check notices for more details") % self.name, e,
                   :request_type => "changesets___delete", :organization => self.environment.organization
    end
    index_repo_content from_env
    raise e
  end

  def delete_products from_env
    self.products.each do |product|
      next if (products.uniq! or []).include? product
      product.delete_from_env(from_env)
    end
  end

  def delete_repos from_env
    self.repos.each do |repo|
      product = repo.product
      next if (products.uniq! or []).include? product
      repo.destroy
    end
  end

  def delete_views from_env
    self.content_views.each do |view|
      view.delete(from_env)
    end
  end

  def delete_packages from_env
    #repo->list of pkg_ids
    pkgs_delete = { }
    not_included_packages.each do |pkg|
      product = pkg.product
      product.repos(from_env).each do |repo|
        if (repo.has_package? pkg.package_id)
          @affected_repos << repo
          pkgs_delete[repo] ||= []
          pkgs_delete[repo] << pkg.package_id
        end
      end
    end
    total_pkg_ids = []

    pkgs_delete.each_pair do |repo, pkg_ids|
      total_pkg_ids  += pkg_ids
      repo.delete_packages(pkg_ids)
    end

    Package.index_packages(total_pkg_ids)
  end


  def delete_errata from_env
    # repo->list of errata_ids
    errata_delete = { }

    not_included_errata.each do |errata|
       product = errata.product
       product.repos(from_env).each do |repo|
         if repo.has_erratum? errata.errata_id
           @affected_repos << repo
           errata_delete[repo] ||= []
           errata_delete[repo] << errata.errata_id
         end
       end
    end

    errata_delete.each_pair do |repo, errata|
       repo.delete_errata(errata)
       Errata.index_errata(errata)
    end
  end


  def delete_distributions from_env
    #repo->list of distribution_ids
    distribution_delete = { }

    not_included_distribution.each do |distro|
      product = distro.product
      product.repos(from_env).each do |repo|
        if repo.has_distribution? distro.distribution_id
          @affected_repos << repo
          distribution_delete[repo] = distro.distribution_id
        end
      end
    end

    distribution_delete.each_pair do |repo, distro|
       repo.delete_distribution(distro)
    end
  end

  def affected_repos
    @affected_repos
  end

  def generate_metadata
    async_tasks = affected_repos.collect do |repo|
      repo.generate_metadata
    end
    async_tasks.flatten(1)
  end

end
