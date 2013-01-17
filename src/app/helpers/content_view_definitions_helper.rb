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

module ContentViewDefinitionsHelper
  def definition_type(definition)
    definition.composite ? _('Composite View Definition') : _('View Definition')
  end

  def environments(view_version)
    _("Environment(s): %{environments}") % {:environments => view_version.environments.collect{|e| e.name}.join(', ')}
  end

  def view_checked?(view_id, views_hash=nil)
    return false if views_hash.nil?
    return views_hash.has_key?(view_id)
  end

  def view_repos(definitions)
    view_repos = {}
    definitions.each do |definition|
      definition.content_views.each do |view|
        view_repos[view.id] = {
            :repos => view.repos(current_organization.library).collect{|repo| repo.library_instance_id}
        }
      end
    end
    view_repos
  end

end
