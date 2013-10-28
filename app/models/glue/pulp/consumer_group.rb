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

class Glue::Pulp::ConsumerGroup

  attr_accessor :pulp_id, :consumer_ids

  def set_pulp_consumer_group
    Rails.logger.debug "creating pulp consumer group '#{self.pulp_id}'"
    Katello.pulp_server.extensions.consumer_group.create(self.pulp_id, :consumer_ids => (consumer_ids || []))
  rescue => e
    Rails.logger.error "Failed to create pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def del_pulp_consumer_group
    Rails.logger.debug "deleting pulp consumer group '#{self.pulp_id}'"
    Katello.pulp_server.extensions.consumer_group.delete(self.pulp_id)
  rescue => e
    Rails.logger.error "Failed to delete pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def install_package(packages)
    Rails.logger.debug "Scheduling package install for consumer group #{self.pulp_id}"

    Katello.pulp_server.extensions.consumer_group.install_content(self.pulp_id,
                                                                    'rpm',
                                                                    packages,
                                                                    {'importkeys' => true})
  rescue => e
    Rails.logger.error "Failed to schedule package install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def uninstall_package(packages)
    Rails.logger.debug "Scheduling package uninstall for consumer group #{self.pulp_id}"

    Katello.pulp_server.extensions.consumer_group.uninstall_content(self.pulp_id,
                                                                      'rpm',
                                                                      packages)
  rescue => e
    Rails.logger.error "Failed to schedule package uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def update_package(packages)
    Rails.logger.debug "Scheduling package update for consumer group #{self.pulp_id}"

    options = {"importkeys" => true}
    options[:all] = true if packages.blank?
    Katello.pulp_server.extensions.consumer_group.update_content(self.pulp_id,
                                                                   'rpm',
                                                                   packages,
                                                                   options)
  rescue => e
    Rails.logger.error "Failed to schedule package update for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def install_package_group(groups)
    Rails.logger.debug "Scheduling package group install for consumer group #{self.pulp_id}"

    Katello.pulp_server.extensions.consumer_group.install_content(self.pulp_id,
                                                                    'package_group',
                                                                    groups,
                                                                    {'importkeys' => true})
  rescue => e
    Rails.logger.error "Failed to schedule package group install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def uninstall_package_group(groups)
    Rails.logger.debug "Scheduling package group uninstall for consumer group #{self.pulp_id}"

    Katello.pulp_server.extensions.consumer_group.uninstall_content(self.pulp_id,
                                                                      'package_group',
                                                                      groups)
  rescue => e
    Rails.logger.error "Failed to schedule package group uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def install_consumer_errata(errata_ids)
    Rails.logger.debug "Scheduling errata install for consumer group #{self.pulp_id}"

    Katello.pulp_server.extensions.consumer_group.install_content(self.pulp_id,
                                                                    'erratum',
                                                                    errata_ids,
                                                                    {'importkeys' => true})
  rescue => e
    Rails.logger.error "Failed to schedule errata install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

end
