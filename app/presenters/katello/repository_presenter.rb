module Katello
  class RepositoryPresenter
    attr_accessor :repository

    def initialize(repository)
      @repository = repository
    end

    def content_view_environments
      unarchived = @repository.clones.select { |clone| clone.environment && clone.content_view_version }

      unarchived.collect do |repository|
        if repository.environment && repository.content_view_version
          {
            :content_view_version => {
              :id => repository.content_view_version.id,
              :name => repository.content_view_version.name
            },
            :environment => {
              :id => repository.environment.id,
              :name => repository.environment.name
            }
          }
        end
      end
    end
  end
end
