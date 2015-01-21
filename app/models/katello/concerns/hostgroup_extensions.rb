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
        before_save :add_organization_for_environment

        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hostgroups
        belongs_to :content_view, :inverse_of => :hostgroups, :class_name => "::Katello::ContentView"
        belongs_to :lifecycle_environment, :inverse_of => :hostgroups, :class_name => "::Katello::KTEnvironment"

        validates_with Katello::Validators::ContentViewEnvironmentValidator

        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source
        scoped_search :in => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :in => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment
      end

      def content_view
        return super unless ancestry.present?
        Katello::ContentView.find_by_id(inherited_content_view_id)
      end

      def lifecycle_environment
        return super unless ancestry.present?
        Katello::KTEnvironment.find_by_id(inherited_lifecycle_environment_id)
      end

      # instead of calling nested_attribute_for(:content_source_id) in Foreman, define the methods explictedly
      def content_source
        return super unless ancestry.present?
        SmartProxy.find_by_id(inherited_content_source_id)
      end

      def inherited_content_source_id
        inherited_ancestry_attribute(:content_source_id)
      end

      def inherited_content_view_id
        inherited_ancestry_attribute(:content_view_id)
      end

      def inherited_lifecycle_environment_id
        inherited_ancestry_attribute(:lifecycle_environment_id)
      end

      def rhsm_organization_label
        #used for rhsm registration snippet, since hostgroup can belong to muliple organizations, use lifecycle environment or cv
        (self.lifecycle_environment || self.content_view).try(:organization).try(:label)
      end

      def add_organization_for_environment
        #ensures that the group's orgs include whatever lifecycle environment is assigned
        if self.lifecycle_environment && !self.organizations.include?(self.lifecycle_environment.organization)
          self.organizations << self.lifecycle_environment.organization
        end
      end

      def content_and_puppet_match?
        self.content_view && self.lifecycle_environment && self.content_view == self.environment.try(:content_view) &&
            self.lifecycle_environment == self.environment.try(:lifecycle_environment)
      end

      private

      def inherited_ancestry_attribute(attribute)
        if ancestry.present?
          self[attribute] || self.class.sort_by_ancestry(ancestors.where("#{attribute.to_s} is not NULL")).last.try(attribute)
        else
          self.send(attribute)
        end
      end
    end
  end
end

class ::Hostgroup::Jail < Safemode::Jail
  allow :content_source, :rhsm_organization_label
end
