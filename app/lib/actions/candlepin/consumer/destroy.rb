module Actions
  module Candlepin
    module Consumer
      class Destroy < Candlepin::Abstract
        input_format do
          param :uuid
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.destroy(input[:uuid])
        end
      end
    end
  end
end
