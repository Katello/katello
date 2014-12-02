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

module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Clone < Actions::Base
        attr_accessor :new_puppet_environment

        def plan(from_version, options)
          environment = options[:environment]
          new_version = options[:new_version]
          source = from_version.content_view_puppet_environments.archived.first

          if environment
            clone = find_or_build_puppet_env(from_version, environment)
          else
            clone = find_or_build_puppet_archive(new_version)
          end

          sequence do
            if clone.new_record?
              plan_action(ContentViewPuppetEnvironment::Create, clone, true)
            else
              clone.content_view_version = from_version
              clone.save!
              plan_action(ContentViewPuppetEnvironment::Clear, clone)
            end

            self.new_puppet_environment = clone
            plan_action(Pulp::Repository::CopyPuppetModule,
                        source_pulp_id: source.pulp_id,
                        target_pulp_id: clone.pulp_id,
                        criteria: nil)

            concurrence do
              plan_action(Katello::Repository::MetadataGenerate, clone) if environment
              plan_action(ElasticSearch::ContentViewPuppetEnvironment::IndexContent, id: clone.id)
              handle_capsule_content(environment, clone)
            end
          end
        end

        private

        def handle_capsule_content(environment, clone)
          sequence do
            if environment
              ::Katello::CapsuleContent.with_environment(environment).each do |capsule_content|
                plan_action(CapsuleContent::AddRepository, capsule_content, clone)
              end
            end
          end
        end

        # The environment clone clone of the repository is the one
        # visible for the systems in the environment
        def find_or_build_puppet_env(version, environment)
          puppet_env = ::Katello::ContentViewPuppetEnvironment.in_content_view(version.content_view).
              in_environment(environment).scoped(:readonly => false).first
          puppet_env = version.content_view.build_puppet_env(:environment => environment) unless puppet_env
          puppet_env
        end

        def find_or_build_puppet_archive(new_version)
          puppet_env = new_version.archive_puppet_environment
          puppet_env = new_version.content_view.build_puppet_env(:version => new_version) unless puppet_env
          puppet_env
        end
      end
    end
  end
end
