module Katello
  module Pulp
    class ModuleStream < PulpContentUnit
      include LazyAccessor

      CONTENT_TYPE = "modulemd".freeze
    end
  end
end
