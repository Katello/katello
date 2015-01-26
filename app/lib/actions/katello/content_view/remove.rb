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
    module ContentView
      class Remove < Actions::EntryAction
        # Remove content view versions and/or environments from a content view

        # Options: (note that all are optional)
        # content_view_environments - content view environments to delete
        # content_view_versions - view versions to delete
        # system_content_view_id - content view to reassociate systems with
        # system_environment_id - environment to reassociate systems with
        # key_content_view_id - content view to reassociate actvation keys with
        # key_environment_id - environment to reassociate activation keys with'
        # organization_destroy
        # rubocop:disable MethodLength
        def plan(content_view, options)
          cv_envs = options.fetch(:content_view_environments, [])
          versions = options.fetch(:content_view_versions, [])
          organization_destroy = options.fetch(:organization_destroy, false)
          skip_elastic = options.fetch(:skip_elastic, false)
          skip_repo_destroy = options.fetch(:skip_repo_destroy, false)
          action_subject(content_view)
          validate_options(content_view, cv_envs, versions, options) unless organization_destroy

          all_cv_envs = combined_cv_envs(cv_envs, versions)

          sequence do
            concurrence do
              all_cv_envs.each do |cv_env|
                if cv_env.systems.any? || cv_env.activation_keys.any?
                  plan_action(ContentViewEnvironment::ReassignObjects, cv_env, options)
                end
              end
            end

            cv_histories = []
            all_cv_envs.each do |cve|
              cv_histories << ::Katello::ContentViewHistory.create!(:content_view_version => cve.content_view_version,
                                                                    :user => ::User.current.login,
                                                                    :environment => cve.environment,
                                                                    :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                                    :task => self.task)
              plan_action(ContentViewEnvironment::Destroy,
                          cve,
                          :skip_elastic => skip_elastic,
                          :skip_repo_destroy => skip_repo_destroy,
                          :organization_destroy => organization_destroy)
            end

            versions.each do |version|
              ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                    :user => ::User.current.login,
                                                    :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task)
              plan_action(ContentViewVersion::Destroy, version)
            end

            plan_self(content_view_id: content_view.id,
                      environment_ids: cv_envs.map(&:environment_id),
                      environment_names: cv_envs.map { |cve| cve.environment.name },
                      version_ids: versions.map(&:id),
                      content_view_history_ids: cv_histories.map { |history| history.id })
          end
        end

        def humanized_name
          _("Remove Versions and Associations")
        end

        def finalize
          input[:content_view_history_ids].each do |history_id|
            history = ::Katello::ContentViewHistory.find_by_id(history_id)
            if history
              history.status = ::Katello::ContentViewHistory::SUCCESSFUL
              history.save!
            end
          end
        end

        def validate_options(_content_view, cv_envs, versions, options)
          if cv_envs.empty? && versions.empty?
            fail _("Either environments or versions must be specified.")
          end
          all_cv_envs = combined_cv_envs(cv_envs, versions)

          if all_cv_envs.flat_map(&:systems).any? && system_cve(options).nil?
            fail _("Unable to reassign systems. Please check system_content_view_id and system_environment_id.")
          end

          if all_cv_envs.flat_map(&:activation_keys).any? && activation_key_cve(options).nil?
            fail _("Unable to reassign activation_keys. Please check activation_key_content_view_id and activation_key_environment_id.")
          end

          if all_cv_envs.flat_map(&:distributors).any?
            fail _("Unable to perform removal. Please reassign any attached distributors first.")
          end
        end

        def combined_cv_envs(cv_envs, versions)
          (cv_envs + versions.flat_map(&:content_view_environments)).uniq
        end

        def system_cve(options)
          ::Katello::ContentViewEnvironment.where(:environment_id => options[:system_environment_id],
                                                  :content_view_id => options[:system_content_view_id]
                                      ).first
        end

        def activation_key_cve(options)
          ::Katello::ContentViewEnvironment.where(:environment_id => options[:key_environment_id],
                                                  :content_view_id => options[:key_content_view_id]
                                      ).first
        end
      end
    end
  end
end
