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
