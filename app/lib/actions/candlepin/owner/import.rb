module Actions
  module Candlepin
    module Owner
      class Import < Candlepin::Abstract
        input_format do
          param :label
          param :path
          param :force
          param :upstream
        end

        def run
          options = input.slice(:force, :upstream)
          output[:response] = ::Katello::Resources::Candlepin::Owner.import(input[:label], input[:path], options)
        end
      end
    end
  end
end
