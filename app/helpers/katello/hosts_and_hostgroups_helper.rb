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
  module HostsAndHostgroupsHelper
    def kt_ak_label
      "kt_activation_keys"
    end

    def envs_by_kt_org
      ::Environment.all.find_all(&:katello_id).group_by do |env|
        if env.katello_id
          env.katello_id.split('/').first
        end
      end
    end

    def grouped_env_options
      grouped_options = envs_by_kt_org.sort_by(&:first).map do |kt_org_label, envs_by_org|
        optgroup = %(<optgroup label="#{kt_org_label}">)

        opts = envs_by_org.sort_by(&:katello_id).reduce({}) do |env_options, env|
          selected = env.id == (@host || @hostgroup).environment_id ? "selected" : ""
          kt_env_label = env.katello_id.split('/')[1]
          selected.blank? ? env_options[kt_env_label] ||= selected : env_options[kt_env_label] = selected
          env_options
        end

        opts = opts.sort_by(&:first).map do |kt_env_label, selected|
          kt_env = Katello::KTEnvironment.joins(:organization).
              where("#{Katello::KTEnvironment.table_name}.label" => kt_env_label).
              where("#{::Organization.table_name}.label" => kt_org_label).first

          %(<option value="#{kt_org_label}/#{kt_env_label}"
                    class="kt-env" data-katello-env-id="#{kt_env.try(:id)}"
                    #{selected}>#{kt_env_label}</option>)

        end

        optgroup << opts.join
        optgroup << '</optgroup>'
      end
      grouped_options = grouped_options.join
      grouped_options.insert(0, %(<option value=""></option>))
      grouped_options.html_safe
    end

    def content_view_options
      cv_options = ::Environment.order(:katello_id).all.map do |env|
        selected = env.id == (@host || @hostgroup).environment_id ? "selected" : ""

        if env.katello_id
          # rubocop:disable UselessAssignment
          org_label, kt_env_label, content_view_label = env.katello_id.split('/')
          option_text = content_view_label
        else
          option_text = env.name
        end

        content_view = Katello::ContentView.joins(:organization).
            where("#{Katello::ContentView.table_name}.label" => content_view_label).
            where("#{::Organization.table_name}.label" => org_label).first

        %(<option value="#{env.id}"
                  data-katello-id="#{env.katello_id}"
                  data-content_view-id="#{content_view.try(:id)}"
                  #{selected}>#{option_text}</option>)
      end

      return cv_options.join.html_safe
    end
  end
end
