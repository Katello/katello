module Katello
  module Api
    module V2
      module Rendering

        RESOURCE_ROOT = "result"
        COLLECTION_ROOT = "results"

        def respond_for_show(options = {})
          respond_with_template_resource(options[:template] || 'show', controller_name, options)
        end

        def respond_for_index(options = {})
          try_specific_collection_template(options[:template] || params[:action], params[:action], options)
        end

        def respond_for_create(options = {})
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

        def respond_with_template(action, resource_name, options = {}, &block)
          yield if block_given?
          status = options[:status] || 200

          render :template => "katello/api/v2/common/#{options[:response_type]}",
                 :locals => { :action => action, :resource_name => resource_name, :root_name => options[:root_name] },
                 :status => status
        end

        def respond_with_template_resource(action, resource_name, options = {})
          options[:response_type] = "resource"
          options[:root_name] = RESOURCE_ROOT
          respond_with_template(action, resource_name, options) do
            @resource = options[:resource] unless options[:resource].nil?
            @resource = get_resource if @resource.nil?
          end
        end

        def respond_with_template_collection(action, resource_name, options = {})
          options[:response_type] = "collection"
          options[:root_name] = COLLECTION_ROOT
          respond_with_template(action, resource_name, options) do
            @collection = options[:collection] unless options[:collection].nil?
            @collection = get_resource_collection if @collection.nil?
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
