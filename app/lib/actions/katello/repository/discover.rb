module Actions
  module Katello
    module Repository
      class Discover < Actions::Base
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
          repo_discovery = ::Katello::RepoDiscovery.new(input[:url], proxy)
          output[:repo_urls] = []
          found = lambda { |path| output[:repo_urls] << path }
          # TODO: implement task cancelling
          continue = lambda { true }
          repo_discovery.run(found, continue)
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
