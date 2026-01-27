module Actions
  module Middleware
    class AutoPublishContext < Dynflow::Middleware
      def plan(*args)
        pass(*args).tap do
          resource = args.first
          case resource
          when ::Katello::ContentView
            action.input[:auto_publish_content_view_id] = resource.id
          when ::Katello::ContentViewVersion
            action.input[:auto_publish_content_view_id] = resource.content_view_id
          else
            fail "Can't determine auto publish content view from #{resource.class}"
          end
        end
      end
    end
  end
end
