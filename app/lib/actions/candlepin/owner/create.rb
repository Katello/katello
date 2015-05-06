module Actions
  module Candlepin
    module Owner
      class Create < Candlepin::Abstract
        input_format do
          param :name
          param :label
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Owner.create(input[:label], input[:name])
        end
      end
    end
  end
end
