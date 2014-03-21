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
class BulkActions

  attr_accessor :systems, :user, :organization

  def initialize(user, org, systems)
    self.systems = systems
    self.organization = org
    self.user = user
  end

  def install_errata(errata_ids)
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.install_consumer_errata(errata_ids)
      save_job(pulp_job, :errata_install, :errata_ids, errata_ids)
    end
  end

  def install_packages(packages)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.install_package(packages)
      save_job(pulp_job, :package_install, :packages, packages)
    end
  end

  def uninstall_packages(packages)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.uninstall_package(packages)
      save_job(pulp_job, :package_remove, :packages, packages)
    end
  end

  def update_packages(packages = nil)
    # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.update_package(packages)
      save_job(pulp_job, :package_update, :packages, packages)
    end
  end

  def install_package_groups(groups)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.install_package_group(groups)
      save_job(pulp_job, :package_group_install, :groups, groups)
    end
  end

  def update_package_groups(groups)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.install_package_group(groups)
      save_job(pulp_job, :package_group_update, :groups, groups)
    end
  end

  def uninstall_package_groups(groups)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_bulk_action do |consumer_group|
      pulp_job = consumer_group.uninstall_package_group(groups)
      save_job(pulp_job, :package_group_remove, :groups, groups)
    end
  end

  private

  def perform_bulk_action
    consumer_ids = self.systems.collect{|i| i.uuid}
    group = Glue::Pulp::ConsumerGroup.new
    group.pulp_id = ::UUIDTools::UUID.random_create.to_s
    group.consumer_ids = consumer_ids
    group.set_pulp_consumer_group
    yield(group)
  ensure
    group.del_pulp_consumer_group
  end

  def save_job(pulp_job, job_type, parameters_type, parameters)
    job = Job.create!(:pulp_id => pulp_job.first[:task_group_id], :job_owner => self.user)
    job.create_tasks(self.organization, pulp_job, job_type, parameters_type => parameters)
    job
  end

end
end
