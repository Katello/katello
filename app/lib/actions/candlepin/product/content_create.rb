module Actions
  module Candlepin
    module Product
      class ContentCreate < Candlepin::Abstract
        input_format do
          param :name
          param :type
          param :label
          param :content_url
          param :owner
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Content.
              create(input[:owner],
                     name: input[:name],
                     contentUrl: input[:content_url],
                     type: input[:type],
                     label: input[:label],
                     metadataExpire: 1,
                     vendor: ::Katello::Provider::CUSTOM)
        end
      end
    end
  end
end
