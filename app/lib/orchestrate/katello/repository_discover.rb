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

module Orchestrate
  module Katello
    class RepositoryDiscover < Dynflow::Action

      input_format do
        param :url, String
      end

      output_format do
        param :repo_urls, array_of(String)
      end

      def plan(url)
        plan_self(url: url)
      end

      def run
        repo_discovery = RepoDiscovery.new(input[:url])
        output[:repo_urls] = []
        found = lambda { |path| output[:repo_urls] << path }
        # TODO: implement task cancelling
        continue = lambda { true }
        repo_discovery.run(found, continue)
      end

      # Get the repositories into task
      def task_output
        { repo_urls: output[:repo_urls] }
      end

    end
  end
end

