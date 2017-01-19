module Actions
  module Katello
    module Repository
      class Discover < Actions::Base
        include Dynflow::Action::Cancellable

        input_format do
          param :url, String
          param :content_type, String
          param :upstream_username, String
          param :upstream_password, String
        end

        output_format do
          param :repo_urls, array_of(String)
        end

        def plan(url, content_type, upstream_username, upstream_password)
          plan_self(url: url, content_type: content_type, upstream_username: upstream_username, upstream_password: upstream_password)
        end

        def run(event = nil)
          output[:repo_urls] = output[:repo_urls] || []
          output[:crawled] = output[:crawled] || []
          output[:to_follow] = output[:to_follow] || [input[:url]]

          repo_discovery = ::Katello::RepoDiscovery.new(input[:url], input[:content_type],
                                                        input[:upstream_username], input[:upstream_password], proxy,
                                                        output[:crawled], output[:repo_urls], output[:to_follow])

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

          if (config = SETTINGS[:katello][:cdn_proxy])
            proxy[:proxy_host] = URI.parse(config[:host]).host if config.key?(:host)
            proxy[:proxy_port] = config[:port] if config.key?(:port)
            proxy[:proxy_user] = config[:user] if config.key?(:user)
            proxy[:proxy_password] = config[:password] if config.key?(:password)
          end

          proxy
        end
      end
    end
  end
end
