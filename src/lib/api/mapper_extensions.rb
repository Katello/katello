
module Katello
  module Routing


    module MapperExtensions

        def api_resources(*args, &block)
          options = args.extract_options!
          options[:except] = Array(options[:except])
          options[:except].push(:new, :edit)

          args << options
          resources(*args, &block)
        end

    end

  end
end
