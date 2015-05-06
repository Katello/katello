module Actions
  module Candlepin
    module Owner
      class Destroy < Candlepin::Abstract
        input_format do
          param :label
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Owner.destroy(input[:label])
        end
      end
    end
  end
end
