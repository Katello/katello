module Actions
  module Candlepin
    module Product
      class ContentUpdate < Candlepin::Abstract
        input_format do
          param :content_id
          param :name
          param :type
          param :label
          param :content_url
          param :gpg_key_url
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Content.
              update(id: input[:content_id],
                     name: input[:name],
                     contentUrl: input[:content_url],
                     gpgUrl: input[:gpg_key_url],
                     type: input[:type],
                     label: input[:label],
                     vendor: ::Katello::Provider::CUSTOM)
        end
      end
    end
  end
end
