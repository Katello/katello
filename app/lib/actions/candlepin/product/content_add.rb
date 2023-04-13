module Actions
  module Candlepin
    module Product
      class ContentAdd < Candlepin::Abstract
        DEFAULT_ENABLEMENT = false

        input_format do
          param :product_id
          param :content_id
          param :owner
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.
              add_content(input[:owner], input[:product_id], input[:content_id], DEFAULT_ENABLEMENT)
        end

        def humanized_name
          _("Add content")
        end

        # results in correct grammar on Tasks page,
        # e.g. "Import manifest for organization Default Organization"
        def humanized_input
          "for Candlepin product #{input[:product_id]}"
        end
      end
    end
  end
end
