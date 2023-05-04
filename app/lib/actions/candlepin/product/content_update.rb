module Actions
  module Candlepin
    module Product
      class ContentUpdate < Candlepin::Abstract
        input_format do
          param :content_id
          param :name
          param :type
          param :arches
          param :os_versions
          param :label
          param :content_url
          param :gpg_key_url
          param :owner
          param :metadata_expire
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Content.
              update(input[:owner],
                     id: input[:content_id],
                     name: input[:name],
                     contentUrl: input[:content_url],
                     gpgUrl: input[:gpg_key_url] || '', #candlepin ignores nil
                     type: input[:type],
                     arches: input[:arches] || '',
                     requiredTags: input[:os_versions],
                     label: input[:label],
                     metadataExpire: input[:metadata_expire] || 1,
                     vendor: ::Katello::Provider::CUSTOM)
        end
      end
    end
  end
end
