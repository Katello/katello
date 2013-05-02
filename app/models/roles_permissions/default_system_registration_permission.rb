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

module RolesPermissions::DefaultSystemRegistrationPermission
  include ::ProxyAssociationOwner

  NAME = "default systems reg permission"

  def find_default_system_registration_permission
    resource_type = ResourceType.find_or_create_by_name("environments")
    verb          = Verb.find_or_create_by_verb("register_systems")

    _find_default_system_registration_permission(resource_type, verb)
  end

  def create_default_system_registration_permission(oranization, environment)
    resource_type = ResourceType.find_or_create_by_name("environments")
    verb          = Verb.find_or_create_by_verb("register_systems")

    proxy_association_owner.permissions.create!(:resource_type => resource_type, :verbs => [verb], :name => NAME, :organization => oranization).tap do |p|
      p.tags.create! :tag_id => environment.id
    end
  end

  def update_default_system_registration_permission(environment)
    resource_type = ResourceType.find_or_create_by_name("environments")
    verb          = Verb.find_or_create_by_verb("register_systems")

    p = _find_default_system_registration_permission(resource_type, verb)
    p.tags.first.update_attributes!(:tag_id => environment.id)
  end

  def _find_default_system_registration_permission(resource_type, verb)
    joins(:verbs).
        where(:resource_type_id => resource_type, :verbs => { :id => verb }, :name => NAME).first
  end
end