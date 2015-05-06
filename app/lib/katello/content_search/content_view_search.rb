module Katello
  module ContentSearch
    class ContentViewSearch < ContainerSearch
      attr_accessor :views, :organization

      def initialize(options)
        super
        self.rows = build_rows
      end

      def build_rows
        filtered_views.collect do |view|
          cols = {}
          view.environments.collect do |env|
            if readable_env_ids(organization).include?(env.id)
              if view.default?
                display = ""
              else
                version = view.version(env).try(:version)
                display = version ? (_("version %s") % version) : ""
              end
              cols[env.id] = Cell.new(:hover => lambda { container_hover_html(view, env) },
                                      :hover_details => lambda { container_hover_html(view, env, nil, true) },
                                      :display => display)
            end
          end

          Row.new(:id         => "view_#{view.id}",
                  :name       => view.name,
                  :cells      => cols,
                  :data_type  => "view",
                  :value      => view.name,
                  :comparable => self.comparable,
                  :object_id  => view.id
                 )
        end
      end

      def view_versions
        @view_versions ||= begin
          versions = views.map { |v| v.versions.in_environment(search_envs) }.flatten
          if @mode == 'unique'
            versions = versions.select { |v| !(search_envs - v.environments).empty? }
          elsif @mode == 'shared'
            versions = versions.select { |v| (search_envs - v.environments).empty? }
          end
          versions
        end
      end

      # views that have been filtered by search_mode
      def filtered_views
        @filtered_views ||= @views.select { |v| view_versions.map(&:content_view_id).include?(v.id) }
      end
    end
  end
end
