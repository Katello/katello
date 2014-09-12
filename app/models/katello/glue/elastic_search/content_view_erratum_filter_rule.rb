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
  module Glue::ElasticSearch::ContentViewErratumFilterRule
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => { :only => [:id,
                                         :errata_id,
                                         :start_date,
                                         :end_date,
                                         :types,
                                         :created_at,
                                         :updated_at]
                             },
                    :display_attrs => [:name]

      mapping do
        indexes :errata_id, :type => 'string', :analyzer => :snowball
        indexes :errata_id_sort, :type => 'string', :index => :not_analyzed
      end
    end

    def extended_index_attrs
      {
        :content_view_filter_id => self.content_view_filter_id
      }
    end
  end
end
