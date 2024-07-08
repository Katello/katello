module Actions
  module Katello
    module Foreman
      class ContentUpdate < Actions::Katello::Foreman::Abstract
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(environment, content_view, repo = nil)
          plan_self(environment_id: environment.id,
                    content_view_id: content_view.id,
                    repository_id: repo.try(:id))
        end

        input_format do
          param :environment_id
          param :content_view_id
        end

        def finalize
          User.as_anonymous_admin do
            content_view = ::Katello::ContentView.find(input[:content_view_id])
            repository = ::Katello::Repository.find(input[:repository_id]) if input[:repository_id]

            if content_view.default? && repository && repository.distribution_bootable?
              os = Redhat.find_or_create_operating_system(repository)
              arch = Architecture.where(:name => repository.distribution_arch).first_or_create!
              os.architectures << arch unless os.architectures.include?(arch)
            end
          end
        end
      end
    end
  end
end
