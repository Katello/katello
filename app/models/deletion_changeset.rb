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



class DeletionChangeset < Changeset
  use_index_of Changeset
  def apply(options = { })
    options = { :async => true, :notify => false }.merge options

    self.state == Changeset::REVIEW or
        raise _("Cannot delete the changset '%s' because it is not in the review phase.") % self.name

    #check for other changesets promoting
    if self.environment.promoting_to?
      raise _("Cannot delete the changeset '%s' while another changeset (%s) is being deleted or promoted.") %
                [self.name, self.environment.promoting.first.name]
    end

    validate_content! self.errata
    validate_content! self.packages
    validate_content! self.distributions

    self.state = Changeset::DELETING
    self.save!

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

    logger.info("Delete content!")
    delete_products(from_env)
    update_progress! '30'
    # PulpTaskStatus::wait_for_tasks delete_templates(from_env)
    # update_progress! '50'
    delete_repos from_env
    update_progress! '70'
    from_env.update_cp_content
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

    # index_repo_content from_env

    if notify
      message = _("Successfully deleted changeset '%s'.") % self.name
      Notify.message message, :request_type => "changesets___delete"
    end

  rescue Exception => e
    self.state = Changeset::FAILED
    self.save!
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    if notify
      Notify.exception _("Failed to delete changeset '%s'. Check notices for more details") % self.name, e,
                   :request_type => "changesets___delete"
    end
    index_repo_content from_env
    raise e
  end


  def delete_templates from_env
    # TODO
    # async_tasks = self.system_templates.collect do |tpl|
    #   tpl.promote from_env, to_env
    # end
    # async_tasks.flatten(1)
  end


  def delete_products from_env
    async_tasks = self.products.collect do |product|
      next if (products.uniq! or []).include? product
      product.delete_from_env(from_env)
    end
    async_tasks.flatten(1)
  end


  def delete_repos from_env
    self.repos.each do |repo|
      product = repo.product
      next if (products.uniq! or []).include? product

      product.delete_repo_by_id(repo.id)
    end
  end

  def delete_packages from_env
    #repo->list of pkg_ids
    pkgs_delete = { }
    
    not_included_packages.each do |pkg|
      product = pkg.product
      product.repos(from_env).each do |repo|
        if (repo.has_package? pkg.package_id)
          pkgs_delete[repo] ||= []
          pkgs_delete[repo] << pkg.package_id
        end
      end
    end
    
    pkgs_delete.each_pair do |repo, pkgs|
      repo.delete_packages(pkgs)
      Glue::Pulp::Package.index_packages(pkgs)
    end
  end


  def delete_errata from_env
    # repo->list of errata_ids
    errata_delete = { }

    not_included_errata.each do |errata|
       product = errata.product
       product.repos(from_env).each do |repo|
         if repo.has_erratum? errata.errata_id
           errata_delete[repo] ||= []
           errata_delete[repo] << errata.errata_id
         end
       end
    end

    errata_delete.each_pair do |repo, errata|
       repo.delete_errata(errata)
       Glue::Pulp::Errata.index_errata(errata)
    end
  end


  def delete_distributions from_env
    #repo->list of distribution_ids
    distribution_delete = { }

    not_included_distribution.each do |distro|
      product = distro.product
      product.repos(from_env).each do |repo|
        if repo.has_distribution? distro.distribution_id
          distribution_delete[repo] = distro.distribution_id
        end
      end
    end

    distribution_delete.each_pair do |repo, distro|
       repo.delete_distribution(distro)
    end
  end

  def affected_repos
    repos = []
    repos += self.packages.collect { |e| e.repositories }.flatten(1)
    repos += self.errata.collect { |e| e.repositories }.flatten(1)
    repos += self.distributions.collect { |d| d.repositories }.flatten(1)
    repos.uniq
  end

  # def repos_to_be_promoted
  #   repos = self.repos || []
  #   repos += self.system_templates.map { |tpl| tpl.repos_to_be_promoted }.flatten(1)
  #   return repos.uniq
  # end
  # 
  # def products_to_be_promoted
  #   products = self.products || []
  #   products += self.system_templates.map { |tpl| tpl.products_to_be_promoted }.flatten(1)
  #   return products.uniq
  # end  
  # 
  def generate_metadata
    async_tasks = affected_repos.collect do |repo|
      repo.generate_metadata
    end
    async_tasks
  end

end