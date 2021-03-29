module Actions
  module Katello
    module JailConcern
      module Organization
        def organization_id
          input['organization']['id']
        end

        def organization_name
          input['organization']['name']
        end

        def organization_label
          input['organization']['label']
        end

        def self.included(base)
          super
          base.instance_eval do
            apipie :class do
              property :organization_id, Integer, desc: 'Returns the id of the organization'
              property :organization_name, String, desc: 'Returns the name of the organization'
              property :organization_label, String, desc: 'Returns the label of the organization'
            end
          end
        end
      end
    end
  end
end
