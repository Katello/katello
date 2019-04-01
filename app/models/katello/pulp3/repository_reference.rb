module Katello
  module Pulp3
    class RepositoryReference < Katello::Model
      belongs_to :root_repository, :class_name => 'Katello::RootRepository'
      belongs_to :content_view, :class_name => 'Katello::ContentView'
    end
  end
end
