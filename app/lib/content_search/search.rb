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

# a span represents a collection of rows. usually these rows represent
# a container like a product or content view

module ContentSearch

  class Search
    include Element
    display_attributes :rows, :name, :cols
    attr_accessor :mode

    def current_organization
      SearchUtils.current_organization
    end

    def render_to_string(*args)
      av =  ActionView::Base.new(ActionController::Base.view_paths, {})
      av.render(*args)
    end


    def mode
      @mode || :all
    end

    def offset
      SearchUtils.offset
    end

    def page_size
      SearchUtils.page_size
    end
  end

end
