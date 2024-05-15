module Katello
  module Routing
    module MapperExtensions
      def api_resources(*args, &block)
        options          = args.extract_options!
        options[:except] = Array(options[:except])
        options[:except].push(:new, :edit)

        args << options
        resources(*args, &block)
      end

      def api_attachable_resources(resource_plural_name, options = {})
        resource_singular_name = options.try(:delete, :resource_name)
        resource_singular_name ||= resource_plural_name.to_s.singularize

        controller = options.delete(:controller)

        api_resources resource_plural_name, :controller => controller, :only => [] do
          params = { :on => :collection, :action => "add_" + resource_singular_name.to_s }
          post :index, params.merge(options)

          params = { :on => :member, :action => "remove_" + resource_singular_name.to_s }
          delete :destroy, params.merge(options)
        end
      end
    end
  end
end
