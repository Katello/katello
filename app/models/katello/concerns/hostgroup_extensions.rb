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
        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hostgroups
        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source
      end

      # instead of calling nested_attribute_for(:content_source_id) in Foreman, define the methods explictedly
      def inherited_content_source_id
        if ancestry.present?
          self[:content_source_id] || self.class.sort_by_ancestry(ancestors.where("content_source_id is not NULL")).last.try(:content_source_id)
        else
          self.content_source_id
        end
      end

      def content_source
        return super unless ancestry.present?
        SmartProxy.find_by_id(inherited_content_source_id)
      end

    end
  end
end

class ::Hostgroup::Jail < Safemode::Jail
  allow :content_source
end
