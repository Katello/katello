module Actions
  module Pulp3
    module ContentViewVersion
      class CreateImportHistory < Actions::EntryAction
        input_format do
          param :content_view_version_id, Integer
          param :path, String
          param :metadata, Hash
          param :content_view_name, String
        end

        output_format do
          param :import_history_id, Integer
        end

        def run
          history = ::Katello::ContentViewVersionImportHistory.create!(
            content_view_version_id: input[:content_view_version_id],
            path: input[:path],
            metadata: input[:metadata],
            audit_comment: ::Katello::ContentViewVersionImportHistory.generate_audit_comment(user: User.current,
                                                                                             content_view_name: input[:content_view_name])
          )
          output[:import_history_id] = history.id
        end

        def humanized_name
          _("Create Import History")
        end
      end
    end
  end
end
