module Actions
  module Candlepin
    module Product
      class ContentCreate < Candlepin::Abstract
        input_format do
          param :name
          param :type
          param :label
          param :content_url
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Content.
              create(name: input[:name],
                     contentUrl: input[:content_url],
                     type: input[:type],
                     label: input[:label],
                     vendor: ::Katello::Provider::CUSTOM)
        end
      end
    end
  end
end
