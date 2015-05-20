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
  module Glue::ElasticSearch::ContentViewHistory
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => {:only => [:user, :id, :created_at, :updated_at]}

      mapping do
        indexes :version_id, :type => 'integer'
        indexes :created_at, :type => 'date'
        indexes :environment, :type => 'string'
        indexes :content_view_id, :type => 'integer'
        indexes :version, :type => 'float'
        indexes :user, :type => 'string'
      end
    end

    def extended_index_attrs
      {
        :environment => self.environment.try(:name),
        :version_id => self.version.id,
        :version => self.version.version,
        :content_view_id => self.content_view.id,
        :environment_id => self.katello_environment_id
      }
    end
  end
end
