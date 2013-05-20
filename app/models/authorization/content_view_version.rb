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

module Authorization::ContentViewVersion
  extend ActiveSupport::Concern

  module ClassMethods
    def readable(org)
      view_ids = ::ContentView.readable(org).collect{|v| v.id}
      joins(:content_view).where("content_views.id" => view_ids)
    end

    def promotable(org)
      items(org, [:promote])
    end

    def items(org, verbs)
      raise "scope requires an organization" if org.nil?
      resource = :content_views

      if User.allowed_all_tags?(verbs, resource, org)
        joins(:content_view).where('content_views.organization_id' => org.id)
      else
        joins(:content_view).where("content_views.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
      end
    end
  end
end
