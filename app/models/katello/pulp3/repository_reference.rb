module Katello
  module Pulp3
    class RepositoryReference < Katello::Model
      belongs_to :root_repository, :class_name => 'Katello::RootRepository'
      belongs_to :content_view, :class_name => 'Katello::ContentView'

      def self.default_cv_repository_hrefs(repositories, organizations)
        organizations = [organizations] if organizations.is_a?(::Organization)
        where(content_view_id: organizations.map(&:default_content_view).compact.pluck(:id)).
            where(root_repository_id: repositories.pluck(:root_id)).
              select(:repository_href).pluck(:repository_href)
      end
    end
  end
end
