module Actions
  module Middleware
    class AutoPublishContext < Dynflow::Middleware
      def plan(*args)
        pass(*args).tap do
          case args.first
          when ::Katello::ContentView
            action.input[:auto_publish_content_view_id] = args.first.id
          when ::Katello::ContentViewVersion
            action.input[:auto_publish_content_view_id] = args.content_view_id
          end
        end
      end
    end
  end
end
