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


module Katello
  module Glue::ElasticSearch::User
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :extended_json => :extended_index_attrs,
                      :display_attrs => [:username, :email],
                      :json          => { :except => [:password, :password_reset_token,
                                                      :password_reset_sent_at, :helptips_enabled,
                                                      :disabled, :login] }

        mapping do
          indexes :username, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :username_sort, :type => 'string', :index => :not_analyzed
        end
      end
    end

    def extended_index_attrs
      { :username_sort => username.downcase }
    end

  end
end
