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

class OrganizationDestroyer

  def self.destroy(organization, options = { })
    OrganizationDestroyer.new(organization, options).setup(organization)
  end

  include AsyncOrchestration
  attr_reader :organization_id, :options

  def initialize(organization, options = { })
    options.assert_valid_keys :user, :async, :notify
    @options      = { :user => User.current, :async => true, :notify => false }.merge options
    @organization_id = organization.id
  end

  def setup(organization)
    raise NotImplementedError unless options[:async]

    task = self.async.run
    organization.deletion_task_id = task.id
    organization.save!
    return task
  end

  def run
    organization = Organization.find(organization_id)
    organization.destroy

    Notify.success _("Successfully removed organization '%s'.") % organization.name,
                   :request_type => "organization__delete", :user => options[:user] if options[:notify]
  rescue => e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))

    Notify.exception _("Failed to delete organization '%s'. Check notices for more details. ") % organization.name, e,
                     :request_type => "organization__delete", :user => options[:user] if options[:notify]
    raise
  end


end

