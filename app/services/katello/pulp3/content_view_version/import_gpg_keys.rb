module Katello
  module Pulp3
    module ContentViewVersion
      class ImportGpgKeys
        attr_accessor :organization, :metadata

        def initialize(organization:, metadata:)
          self.organization = organization
          self.metadata = metadata
        end

        def create_or_update_gpg!(params)
          return if params.blank?
          gpg = organization.gpg_keys.find_by(:name => params[:name])
          if gpg
            gpg.update!(params.except(:name))
          else
            gpg = organization.gpg_keys.create!(params)
          end
          gpg
        end

        def import!
          return if metadata[:gpg_keys].blank?
          metadata[:gpg_keys].values.each do |gpg|
            create_or_update_gpg!(gpg)
          end
        end
      end
    end
  end
end
