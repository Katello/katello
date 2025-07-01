module Katello
  module Concerns
    module Api::V2
      module DynamicParams
        module Repositories
          extend ::Apipie::DSL::Concern

          lazy_update_api(:import_uploads) do
            ::Katello::RepositoryTypeManager.generic_repository_types.each_pair do |_, repo_type|
              repo_type.import_attributes.each do |import_attribute|
                param import_attribute.api_param, import_attribute.type,
                    :desc => N_(import_attribute.description)
              end
            end
          end
        end
      end
    end
  end
end
