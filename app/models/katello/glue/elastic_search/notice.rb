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
  module Glue::ElasticSearch::Notice
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :extended_json => :extended_index_attrs,
                      :json          => { :only => [:text, :created_at, :details, :level] },
                      :display_attrs => [:text, :details, :level, :organization]

        mapping do
          indexes :level_sort, :type => 'string', :index => :not_analyzed
          indexes :created_at, :type => 'date'
        end
      end
    end

    def extended_index_attrs
      { :level_sort   => level.to_s.downcase,
        :user_ids     => self.users.collect { |u| u.id },
        :organization => organization.try(:name) }
    end
  end
end
