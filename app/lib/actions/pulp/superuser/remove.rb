module Actions
  module Pulp
    module Superuser
      class Remove < Abstract
        def operation
          :remove
        end
      end
    end
  end
end
