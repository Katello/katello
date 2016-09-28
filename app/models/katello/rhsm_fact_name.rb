module Katello
  class RhsmFactName < ::FactName
    FACT_TYPE = :rhsm

    def set_name
      self.short_name = self.name.split(SEPARATOR).last
    end

    def origin
      'Redhat'
    end
  end
end
