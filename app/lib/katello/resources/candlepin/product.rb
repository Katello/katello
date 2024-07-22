module Katello
  module Resources
    module Candlepin
      class Product < CandlepinResource
        class << self
          def all(owner_label, included = [])
            products = JSON.parse(Candlepin::CandlepinResource.get(path(owner_label) + "?#{included_list(included)}", self.default_headers).body)
            ::Katello::Util::Data.array_with_indifferent_access products
          end

          def find_for_stacking_id(owner_key, stacking_id)
            Resources::Candlepin::Subscription.get_for_owner(owner_key).each do |subscription|
              if subscription['product']['attributes'].any? { |attr| attr['name'] == 'stacking_id' && attr['value'] == stacking_id }
                return subscription['product']
              end
            end
            nil
          end

          def create(owner_label, attr)
            JSON.parse(self.post(path(owner_label), attr.to_json, self.default_headers).body).with_indifferent_access
          end

          def get(owner_label, id = nil, included = [])
            products_json = super(path(owner_label, id + "/?#{included_list(included)}"), self.default_headers).body
            products = JSON.parse(products_json)
            products = [products] unless id.nil?
            ::Katello::Util::Data.array_with_indifferent_access products
          end

          def product_certificate(id, owner)
            included = %w(certificate product.id providedProducts.id
                          derivedProvidedProducts.id startDate)
            subscriptions_json = Candlepin::CandlepinResource.get(
              "/candlepin/owners/#{owner}/subscriptions?#{included_list(included)}",
              self.default_headers
            ).body
            subscriptions = JSON.parse(subscriptions_json)

            product_subscription = subscriptions.find do |sub|
              sub['certificate'] && Time.parse(sub['startDate']) < Time.now &&
              (sub["product"]["id"] == id ||
                sub["providedProducts"].any? { |provided| provided["id"] == id } ||
                sub["derivedProvidedProducts"].any? { |provided| provided["id"] == id })
            end

            if product_subscription
              return product_subscription["certificate"]
            end
          end

          def certificate(id, owner)
            self.product_certificate(id, owner).try :[], 'cert'
          end

          def key(id, owner)
            self.product_certificate(id, owner).try :[], 'key'
          end

          def destroy(owner_label, product_id)
            fail ArgumentError, "product id has to be specified" unless product_id
            self.delete(path(owner_label, product_id), self.default_headers).code.to_i
          end

          def add_content(owner_label, product_id, content_id, enabled)
            self.post(join_path(path(owner_label, product_id), "content/#{content_id}?enabled=#{enabled}"), nil, self.default_headers).code.to_i
          end

          def remove_content(owner_label, product_id, content_id)
            self.delete(join_path(path(owner_label, product_id), "content/#{content_id}"), self.default_headers).code.to_i
          end

          def create_unlimited_subscription(owner_key, product_id, start_date)
            start_date ||= Time.now

            # Subscription-manager (python-rhsm) can't read the certificate with end date beyond
            # 2049 year correctly. Refer the links below for more details:
            # https://bugzilla.redhat.com/show_bug.cgi?id=1789654
            # https://github.com/candlepin/candlepin/blob/5b87865f304555c112982af4fbc83a1c463d37b2/server/src/main/java/org/candlepin/model/UeberCertificateGenerator.java#L247
            end_date = Time.parse('2049-12-01 00:00:00 +0000')

            pool = {
              'startDate' => start_date,
              'endDate' => end_date,
              'quantity' => -1,
              'accountNumber' => '',
              'productId' => product_id,
              'providedProducts' => [],
              'contractNumber' => '',
            }
            JSON.parse(Candlepin::Pool.create(owner_key, pool))
          end

          def pools(owner_key, product_id)
            Candlepin::Pool.get_for_owner(owner_key).find_all { |pool| pool['productId'] == product_id }
          end

          def delete_subscriptions(owner_key, product_id)
            update_subscriptions = false
            subscriptions = Candlepin::Subscription.get_for_owner owner_key
            subscriptions.each do |s|
              products = ([s['product']] + s['providedProducts'])
              products.each do |p|
                if p['id'] == product_id
                  logger.debug "Deleting subscription: " + s.to_json
                  Candlepin::Subscription.destroy s['id']
                  update_subscriptions = true
                end
              end
            end
            nil
          end

          def path(owner_label, id = nil)
            "/candlepin/owners/#{owner_label}/products/#{id}"
          end

          def update(owner_label, attrs)
            JSON.parse(self.put(path(owner_label, attrs[:id] || attrs['id']), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end
        end
      end
    end
  end
end
