# rubocop:disable AccessModifierIndentation
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
  module Concerns
    module EnvironmentExtensions
      extend ActiveSupport::Concern

      module ClassMethods
        def find_by_katello_id(org, env, content_view)
          katello_id = Environment.construct_katello_id(org, env, content_view)
          Environment.where(:katello_id => katello_id).first
        end

        def create_by_katello_id(org, env, content_view)
          env_name = Environment.construct_name(org, env, content_view)
          katello_id = Environment.construct_katello_id(org, env, content_view)
          Environment.create!(:name => env_name, :organizations => [org], :katello_id => katello_id)
        end

        def find_or_create_by_katello_id(org, env, content_view)
          Environment.find_by_katello_id(org, env, content_view) ||
              Environment.create_by_katello_id(org, env, content_view)
        end

        def construct_katello_id(org, env, content_view)
          fail ArgumentError, "org has to be specified" if org.nil?
          fail ArgumentError, "env has to be specified" if env.nil?
          [org.label, env.label, content_view.label].reject(&:blank?).join('/')
        end

        # content_view_id provides the uniqueness of the name
        def construct_name(org, env, content_view)
          name = ["KT", org.label, env.label, content_view.label, content_view.id].reject(&:blank?).join('_')
          return name.gsub('-', '_')
        end
      end
    end
  end
end
