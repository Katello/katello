# a container represents a product or content view

module Katello
  module ContentSearch
    class ContainerSearch < Search
      attr_accessor :comparable

      def container_hover_html(container, env = nil, view = nil, details = false)
        render_to_string :partial => 'katello/content_search/container_hover',
                         :locals => {:container => container, :env => env, :view => view, :details => details}
      end

      def repo_hover_html(repo, details = false)
        render_to_string :partial => 'katello/content_search/repo_hover',
                         :locals => {:repo => repo, :details => details}
      end

      def env_ids
        SearchUtils.env_ids
      end

      def readable_env_ids(organization)
        ids = []

        if Product.readable?
          ids << organization.library.id if organization.library.readable?
        end

        ids += KTEnvironment.readable.pluck("#{Katello::KTEnvironment.table_name}.id")
        ids.uniq
      end

      def search_envs
        SearchUtils.search_envs(mode)
      end

      #retrieve the list of rows but as values in a hash, with the object id as key
      def row_object_hash
        Hash[self.rows.collect { |r| [r.object_id, r] }]
      end
    end
  end
end
