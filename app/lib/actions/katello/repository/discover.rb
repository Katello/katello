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
    module Repository
      class Discover < Actions::Base
        include Dynflow::Action::Cancellable

        input_format do
          param :url, String
        end

        output_format do
          param :repo_urls, array_of(String)
        end

        def plan(url)
          plan_self(url: url)
        end

        def run(event = nil)
          output[:repo_urls] = output[:repo_urls] || []
          output[:crawled] = output[:crawled] || []
          output[:to_follow] = output[:to_follow] || [input[:url]]

          repo_discovery = ::Katello::RepoDiscovery.new(input[:url], proxy, output[:crawled], output[:repo_urls], output[:to_follow])

          match(event,
            (on nil do
              unless output[:to_follow].empty?
                repo_discovery.run(output[:to_follow].shift)
                suspend { |suspended_action| world.clock.ping suspended_action, 0.001 }
              end
            end),
            (on Dynflow::Action::Cancellable::Cancel do
              output[:repo_urls] = []
            end))
        end

        # @return <String> urls found by the action
        def task_input
          input[:url]
        end

        # @return [Array<String>] urls found by the action
        def task_output
          output[:repo_urls] || []
        end

        def proxy
          proxy = {}

          config = ::Katello.config.cdn_proxy
          proxy[:proxy_host] = URI.parse(config.host).host if config.respond_to?(:host)
          proxy[:proxy_port] = config.port if config.respond_to?(:port)
          proxy[:proxy_user] = config.user if config.respond_to?(:user)
          proxy[:proxy_password] = config.password if config.respond_to?(:password)

          proxy
        end
      end
    end
  end
end
