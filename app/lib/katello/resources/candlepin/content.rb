module Katello
  module Resources
    module Candlepin
      class Content < CandlepinResource
        class << self
          def create(owner_label, attrs)
            JSON.parse(self.post(path(owner_label), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end

          def get(owner_label, id)
            content_json = super(path(owner_label, id), self.default_headers).body
            JSON.parse(content_json).with_indifferent_access
          end

          def all(owner_label, include_only: nil)
            includes = include_only ? "?#{included_list(include_only)}" : ""
            content_json = Candlepin::CandlepinResource.get(path(owner_label) + includes, self.default_headers).body
            JSON.parse(content_json)
          end

          def fetch_content_ids(owner_label)
            content_ids = Set.new
            all(owner_label, include_only: [:id]).each {|ct| content_ids.add(ct['id'])}
            content_ids
          end

          def destroy(owner_label, id)
            fail ArgumentError, "content id has to be specified" unless id

            begin
              self.delete(path(owner_label, id), self.default_headers).code.to_i
            rescue RestClient::NotFound
              # this is OK
              :content_gone
            end
          end

          def update(owner_label, attrs)
            JSON.parse(self.put(path(owner_label, attrs[:id] || attrs['id']), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end

          def path(owner_label, id = nil)
            "/candlepin/owners/#{owner_label}/content/#{id}"
          end
        end
      end
    end
  end
end
