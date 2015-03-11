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
  module ContentSearch
    class RepoSearch < ContainerSearch
      attr_accessor :repos, :view

      def initialize(options)
        super
        self.rows = build_rows
      end

      def self.id(view, repo)
        "view_#{view.id}_product_#{repo.product.id}_repo_#{repo.id}"
      end

      def build_rows
        rows = []

        env_ids = SearchUtils.search_envs(mode).collect { |e| e.id }
        filtered_repos.each do |repo|
          all_repos = repo.environmental_instances(view).pluck(:pulp_id)

          cols = {}
          Repository.non_archived.where(:pulp_id => all_repos).each do |r|
            cols[r.environment.id] = if env_ids.include?(r.environment_id)
                                       Cell.new(:hover => lambda { repo_hover_html(r) },
                                                :hover_details => lambda { repo_hover_html(r, true) })
                                     end
          end

          rows << Row.new(:id => self.class.id(view, repo),
                          :name       => repo.name,
                          :cells      => cols,
                          :data_type  => "repo",
                          :value      => repo.name,
                          :parent_id  => "view_#{view.id}_product_#{repo.product.id}",
                          :comparable => self.comparable,
                          :object_id  => repo.id
                         )
        end
        rows
      end

      def filtered_repos
        filtered = repos
        envs = SearchUtils.search_envs(mode)
        filtered = filtered.select { |repo| !repo.environmental_instances(view).empty? }
        if mode == 'shared'
          filtered = filtered.select { |repo| (envs - repo.environmental_instances(view).collect(&:environment)).empty? }
        elsif mode == 'unique'
          filtered = filtered.select { |repo| !(envs - repo.environmental_instances(view).collect(&:environment)).empty? }
        end
        filtered
      end
    end
  end
end
