module Katello
  module Resources
    module Candlepin
      class OwnerInfo < CandlepinResource
        class << self
          def find(key)
            owner_json = self.get(path(key), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
            JSON.parse(owner_json).with_indifferent_access
          end

          def path(id = nil)
            "/candlepin/owners/#{id}/info"
          end
        end
      end
    end
  end
end
