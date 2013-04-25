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

require 'minitest_helper'


module ContentViewDefinitionSupport

  def self.generate_permissions(cvd, org)
    read_permission = lambda do |user|
      user.can(:read, :content_view_definitions, [cvd.id], org)
    end
    update_permission = lambda do |user|
      user.can(:update, :content_view_definitions, [cvd.id], org)
    end

    create_permission = lambda do |user|
      user.can(:create, :content_view_definitions, nil, org)
    end
    delete_permission = lambda do |user|
      user.can(:delete, :content_view_definitions, [cvd.id], org)
    end

    publish_permission = lambda do |user|
      user.can(:publish, :content_view_definitions, [cvd.id], org)
    end
    OpenStruct.new(
      {
          :readable => [read_permission, update_permission, create_permission,
                        delete_permission, publish_permission],
          :editable => [update_permission, create_permission],
          :read_only => [read_permission, delete_permission, publish_permission]
      })

  end

end
