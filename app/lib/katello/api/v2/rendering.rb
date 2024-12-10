module Katello
  module Api
    module V2
      module Rendering
        def respond_for_show(options = {})
          respond_with_template_resource(options[:template] || 'show', options[:resource_name] || controller_name,
                                         options)
        end

        def respond_for_index(options = {})
          try_specific_collection_template(options[:template] || params[:action], params[:action], options)
        end

        def respond_for_create(options = {})
          options[:status] ||= 201
          try_specific_resource_template(options[:template] || params[:action], params[:action], options)
        end

        def respond_for_update(options = {})
          try_specific_resource_template(options[:template] || params[:action], params[:action], options)
        end

        def respond_for_destroy(options = {})
          try_specific_resource_template(options[:template] || params[:action], params[:action], options)
        end

        def respond_for_status(options = {})
          try_specific_resource_template(options[:template] || params[:action], "status", options)
        end

        def respond_for_async(options = {})
          options[:status] ||= 202
          try_specific_resource_template(options[:template] || params[:action], "async", options)
        end

        def respond_for_bulk_async(options = {})
          options[:status] ||= 202
          try_specific_resource_template(options[:template] || params[:action], "bulk_async", options)
        end

        def respond_with_template(action, resource_name, options = {}, &_block)
          yield if block_given?
          status = options[:status] || 200
          template = options[:full_template] || "katello/api/v2/#{resource_name}/#{action}"

          render :template => template,
                 :status => status,
                 :locals => options.slice(:object_name, :root_name, :locals),
                 :layout => "katello/api/v2/layouts/#{options[:layout]}"
        end

        def respond_with_template_resource(action, resource_name, options = {})
          options[:layout] ||= "resource"
          options[:object_name] = params[:object_name]
          respond_with_template(action, resource_name, options) do
            @resource = options[:resource] unless options[:resource].nil?
            @resource = resource if @resource.nil?
          end
        end

        def respond_with_template_collection(action, resource_name, options = {})
          options[:layout] ||= "collection"
          options[:root_name] = params[:root_name] || "results"
          respond_with_template(action, resource_name, options) do
            @collection = options[:collection] unless options[:collection].nil?
            @collection = resource_collection if @collection.nil?
          end
        end

        def try_specific_resource_template(action, common_action, options = {})
          respond_with_template_resource(action, controller_name, options)
        rescue ActionView::MissingTemplate
          respond_with_template_resource(common_action, "common", options)
        end

        def try_specific_collection_template(action, common_action, options = {})
          respond_with_template_collection(action, controller_name, options)
        rescue ActionView::MissingTemplate
          respond_with_template_collection(common_action, "common", options)
        end
      end # module Rendering
    end # module V2
  end # module Api
end # module Katello
