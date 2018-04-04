module Katello
  module Resources
    module Candlepin
      class CPUser < CandlepinResource
        class << self
          def create(attrs)
            JSON.parse(self.post(path, JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end

          def path(id = nil)
            "/candlepin/users/#{id}"
          end
        end
      end
    end
  end
end
