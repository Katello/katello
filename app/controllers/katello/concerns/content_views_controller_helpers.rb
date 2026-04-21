module Katello
  module Concerns
    module ContentViewsControllerHelpers
      extend ActiveSupport::Concern

      private

      def validate_publish_params!
        if @content_view.rolling?
          fail HttpErrors::BadRequest, _("It's not possible to publish a rolling content view.")
        end
        if params[:repos_units].present? && @content_view.composite?
          fail HttpErrors::BadRequest, _("Directly setting package lists on composite content views is not allowed. Please " \
                                       "update the components, then re-publish the composite.")
        end
        if params[:major].present? && params[:minor].present? && ContentViewVersion.find_by(:content_view_id => params[:id], :major => params[:major], :minor => params[:minor]).present?
          fail HttpErrors::BadRequest, _("A CV version already exists with the same major and minor version (%{major}.%{minor})") % {:major => params[:major], :minor => params[:minor]}
        end

        if params[:major].present? && params[:minor].nil? || params[:major].nil? && params[:minor].present?
          fail HttpErrors::BadRequest, _("Both major and minor parameters have to be used to override a CV version")
        end

        cv_needs_publish = @content_view.needs_publish?
        if (::Foreman::Cast.to_bool(params[:publish_only_if_needed]) && !cv_needs_publish.nil? && !cv_needs_publish)
          fail HttpErrors::BadRequest, _("Content view does not need a publish since there are no audited changes since the last publish." \
                                       " Pass check_needs_publish parameter as false if you don't want to check if content view needs a publish.")
        end
      end

      def ensure_non_default
        if @content_view.default? && !%w(show history).include?(params[:action])
          fail HttpErrors::BadRequest, _("The default content view cannot be edited, published, or deleted.")
        end
      end

      def ensure_non_generated
        if @content_view.import_only?
          fail HttpErrors::BadRequest, _("Import only Content Views cannot be directly publsihed. Content can only be updated by importing into the view.")
        end

        if @content_view.generated?
          fail HttpErrors::BadRequest, _("Generated content views cannot be directly published. They can updated only via export.")
        end
      end

      def view_params
        attrs = [:name, :description, :auto_publish, :solve_dependencies, :import_only,
                 :default, :created_at, :updated_at, :next_version, {:component_ids => []}]
        attrs.push(:label, :composite, :rolling) if action_name == "create"
        if (!@content_view || !@content_view.composite?)
          attrs.push({:repository_ids => []}, :repository_ids)
        end
        result = {}
        result = params.require(:content_view).permit(*attrs).to_h unless action_name == "update" && @content_view.rolling? && params[:content_view].empty?
        # sanitize repository_ids to be a list of integers
        result[:repository_ids] = result[:repository_ids].compact.map(&:to_i) if result[:repository_ids].present?
        result
      end

      def sanitized_environment_ids
        params[:environment_ids]&.compact&.map(&:to_i)
      end

      def validate_environment_ids!(rolling)
        if params[:environment_ids] && !rolling
          fail HttpErrors::BadRequest, _("It's not possible to provide environment_ids for anything other than a rolling content view.")
        end
      end

      def find_environment
        return if !params.key?(:environment_id) && params[:action] == "index"
        @environment = KTEnvironment.readable.find(params[:environment_id])
      end

      def add_use_latest_records(module_records, selected_latest_versions)
        module_records.group_by(&:author).each_pair do |_author, records|
          top_rec = records[0]
          latest = top_rec.dup
          latest.version = _("Always Use Latest (currently %{version})") % { version: latest.version }
          latest.pulp_id = nil
          module_records.delete(top_rec) if selected_latest_versions.include?(top_rec.pulp_id)
          module_records.push(latest)
        end
        module_records
      end
    end
  end
end
