module Actions
  module Candlepin
    module Environment
      class Create < Candlepin::Abstract
        input_format do
          param :organization_label
          param :cp_id
          param :name
          param :description
        end

        def run
          ::Katello::Resources::Candlepin::Environment.create(input['organization_label'],
                                                   input['cp_id'],
                                                   input['name'],
                                                   input['description'])
        end
      end
    end
  end
end
