module Actions
  module Katello
    module Repository
      class CreateRoot < Actions::EntryAction
        def plan(root)
          root.save!
          repository = ::Katello::Repository.new(:environment => root.organization.library,
                                                 :content_view_version => root.organization.library.default_content_view_version,
                                                 :root => root)
          repository.relative_path = repository.custom_repo_path
          repository.save!
          action_subject(repository)
          plan_action(::Actions::Katello::Repository::Create, repository)
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
