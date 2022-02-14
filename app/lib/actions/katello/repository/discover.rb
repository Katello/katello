module Actions
  module Katello
    module Repository
      class Discover < Actions::EntryAction
        include Dynflow::Action::Cancellable
        include EncryptValue

        input_format do
          param :url, String
          param :content_type, String
          param :upstream_username, String
          param :upstream_password, String
          param :search, String
        end

        output_format do
          param :repo_urls, array_of(String)
        end

        def plan(url, content_type, upstream_username, upstream_password, search)
          password = encrypt_field(upstream_password)
          plan_self(url: url, content_type: content_type, upstream_username: upstream_username, upstream_password: password, search: search)
        end

        def run(event = nil)
          output[:repo_urls] = output[:repo_urls] || []
          output[:crawled] = output[:crawled] || []
          output[:to_follow] = output[:to_follow] || [input[:url]]

          match(event,
            (on nil do
              unless output[:to_follow].empty?
                password = decrypt_field(input[:upstream_password])
                repo_discovery = ::Katello::RepoDiscovery.new(input[:url], input[:content_type],
                                                              input[:upstream_username], password,
                                                              input[:search],
                                                              output[:crawled], output[:repo_urls], output[:to_follow])

                repo_discovery.run(output[:to_follow].shift)
                suspend { |suspended_action| world.clock.ping suspended_action, 0.001 }
              end
            end),
            (on Dynflow::Action::Cancellable::Cancel do
              output[:repo_urls] = []
            end))
        end

        # @return [Array<String>] urls found by the action
        def task_output
          output[:repo_urls] || []
        end
      end
    end
  end
end
