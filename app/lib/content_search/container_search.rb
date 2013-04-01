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

# a container represents a product or content view

module ContentSearch
  class ContainerSearch < Search

    def container_hover_html(container, env=nil)
      render_to_string :partial=>'content_search/container_hover',
        :locals=>{:container=>container, :env=>env}
    end

    def env_ids
      SearchUtils.env_ids
    end

    def readable_env_ids
      KTEnvironment.content_readable(current_organization).pluck(:id)
    end

    def search_envs
      SearchUtils.search_envs(mode)
    end

    #retrieve the list of rows but as values in a hash, with the object id as key
    def row_object_hash
      Hash[self.rows.collect { |r| [r.object_id, r] }]
    end
  end
end
