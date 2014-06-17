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
  module Concerns
    module HostgroupExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :pulp_proxy, :class_name => "::SmartProxy", :foreign_key => :pulp_proxy_id, :inverse_of => :hostgroups
        scoped_search :in => :pulp_proxy, :on => :name, :complete_value => true, :rename => :pulp_proxy
      end

      # instead of calling nested_attribute_for(:pulp_proxy_id) in Foreman, define the methods explictedly
      def inherited_pulp_proxy_id
        read_attribute(:inherited_pulp_proxy_id) || self.class.sort_by_ancestry(ancestors.where("pulp_proxy_id is not NULL")).last.try(:pulp_proxy_id) if ancestry.present?
      end

      def pulp_proxy
        return super unless ancestry.present?
        SmartProxy.find_by_id(inherited_pulp_proxy_id)
      end

    end
  end
end
