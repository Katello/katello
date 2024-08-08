module Katello
  module Pulp3
    module ContentViewVersion
      class ImportGpgKeys
        def initialize(organization:, metadata_gpg_keys:)
          @organization = organization
          @metadata_gpg_keys = metadata_gpg_keys
        end

        def create_or_update_gpg!(params)
          gpg = @organization.gpg_keys.find_by(:name => params[:name])
          if gpg
            gpg.update!(params.except(:name))
          else
            gpg = @organization.gpg_keys.create!(params)
          end
          gpg
        end

        def import!
          @metadata_gpg_keys.each do |gpg|
            params = {
              name: gpg.name,
              content_type: ::Katello::ContentCredential::GPG_KEY_TYPE,
              content: gpg.content,
            }

            create_or_update_gpg!(params)
          end
        end
      end
    end
  end
end
