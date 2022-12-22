module Katello
  class ProductContentImporter
    #Example product_content json structure
    # {
    #    "content":{
    #       "uuid":"4028f9f7677f3f4c0167a30cc92c5d55",
    #       "id":"4010",
    #       "type":"file",
    #       "label":"rhel-6-server-satellite-5.7-isos",
    #       "name":"Red Hat Satellite 5.7 (ISOs)",
    #       "vendor":"Red Hat",
    #       "contentUrl":"/content/dist/rhel/server/6/$releasever/$basearch/satellite/5.7/iso",
    #       "requiredTags":"rhel-6-server",
    #       "gpgUrl":"file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release",
    #       "modifiedProductIds":[],
    #       "arches":"x86_64",
    #       "requiredProductIds":[],
    #       "metadataExpire":1,
    #       "releaseVer":null
    #    },
    #    "enabled":false
    # }
    attr_reader :content_url_updated

    def initialize(cp_products = [])
      @contents_to_create = []
      @product_contents_to_create = []
      @product_mapping = {}
      @content_url_updated = []
      @cp_products = cp_products
    end

    def add_product_content(product, product_content_json)
      @product_mapping[product] = product_content_json.map(&:with_indifferent_access)
    end

    def find_product_for_content(content_id)
      prod = @cp_products.find do |prod_json|
        prod_json['productContent'].any? do |product_content_json|
          product_content_json["content"]["id"] == content_id
        end
      end
      ::Katello::Product.find_by(cp_id: prod["id"]) if prod
    end

    def fetch_product_contents_to_move(product, prod_contents_json)
      content_ids = prod_contents_json.map { |pc| pc[:content][:id] }
      # Identify if there are any product_content that should not be
      # part of this product.
      product_contents_to_delete_or_move = product.
                                      product_contents.
                                      joins(:content).
                                      where.not(content: { cp_content_id: content_ids })
      # Identify if product content actually moved between 2 different products
      product_contents_to_delete_or_move.select do |pc|
        content_exists?(product.organization, pc.content)
      end
    end

    def handle_product_moves(product, prod_contents_json)
      product_contents_to_move = fetch_product_contents_to_move(product, prod_contents_json)
      product_contents_to_move.each do |pc|
        content = pc.content
        root_repo = product.root_repositories.find_by(content_id: content.cp_content_id)
        actual_product = find_product_for_content(content.cp_content_id)
        if actual_product.present? && root_repo.present? && root_repo.product != actual_product
          root_repo.update!(product_id: actual_product.id)
          pc.update!(product_id: actual_product.id)
        else
          pc.destroy!
        end
      end

      product.reload unless product_contents_to_move.blank?
    end

    def import
      return if @product_mapping.blank?
      @product_mapping.each do |product, prod_contents_json|
        handle_product_moves(product, prod_contents_json)
        existing_product_contents = product.product_contents.to_a
        prod_contents_json.each do |prod_content_json|
          content = create_or_update_content(product, prod_content_json)
          existing_content_map[content.cp_content_id] = content if content.new_record?
          create_or_update_product_content(product, existing_product_contents, content, prod_content_json[:enabled])
        end
      end
      ::Katello::Content.import(@contents_to_create, recursive: true)
      ::Katello::ProductContent.import(@product_contents_to_create)
    end

    private def existing_content_map
      if @existing_content_map.nil?
        @existing_content_map = {}
        Katello::Content.where(:organization_id => @product_mapping.keys.first.organization.id).to_a.each do |content|
          @existing_content_map[content[:cp_content_id]] = content
        end
      end
      @existing_content_map
    end

    def content_exists?(org, content)
      Resources::Candlepin::Content.get(org.label, content.cp_content_id)
      true
    rescue RestClient::NotFound
      false
    end

    private def create_or_update_content(product, prod_content_json)
      content = existing_content_map[prod_content_json[:content][:id].to_s]
      if content
        update_content(content, prod_content_json)
      else #content does not exist
        content = ::Katello::Content.new(convert_content_attributes(product, prod_content_json))
        @contents_to_create << content
      end
      content
    end

    private def create_or_update_product_content(product, existing_product_contents, content, new_enabled_value)
      product_content = existing_product_contents.find { |pc| pc.content_id == content.id }
      if product_content
        update_product_content(product_content, new_enabled_value)
      else #product_content does not exist
        if content.new_record?
          content.product_contents << ::Katello::ProductContent.new(:product_id => product.id, :enabled => new_enabled_value)
        else
          @product_contents_to_create << ::Katello::ProductContent.new(:product_id => product.id, :content_id => content.id, :enabled => new_enabled_value)
        end
      end
    end

    private def convert_content_attributes(product, product_content_json)
      content = product_content_json[:content]
      {
        cp_content_id: content[:id],
        name: content[:name],
        label: content[:label],
        content_type: content[:type],
        vendor: content[:vendor],
        gpg_url: content[:gpgUrl],
        content_url: content[:contentUrl],
        organization_id: product.organization_id
      }
    end

    #cannot use activerecord-improt to update content, as we rely on after_update callback
    private def update_content(content, prod_content_json)
      attrs_to_update = {}
      new_name = prod_content_json[:content][:name]
      attrs_to_update[:name] = new_name if content.name != new_name

      new_url = prod_content_json[:content][:contentUrl]
      if content.content_url != new_url
        if content.can_update_to_url?(new_url)
          attrs_to_update[:content_url] = new_url
          @content_url_updated << content
        else
          Rails.logger.warn(_("Substitution Mismatch. Unable to update for content: (%{content}). From [%{content_url}] To [%{new_url}].") %
                      { content: content.inspect, content_url: content.content_url, new_url: new_url })
        end
      end
      content.update!(attrs_to_update) unless attrs_to_update.blank?
    end

    private def update_product_content(product_content, new_enabled_value)
      product_content.update!(enabled: new_enabled_value) if product_content.enabled != new_enabled_value
    end
  end
end
