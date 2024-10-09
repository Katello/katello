module Actions
  module Candlepin
    module Product
      class ContentUpdate < Candlepin::Abstract
        input_format do
          param :repository_id
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

        def finalize
          content_url = input[:content_url]
          # We must retrieve the repository in the finalize phase, because Katello::Product::ContentCreate
          # only updates the repository.content_id in the finalize phase!
          repository = ::Katello::Repository.find(input[:repository_id])
          if repository.deb_using_structured_apt?
            content_url += repository.deb_content_url_options
          end

          output[:response] = ::Katello::Resources::Candlepin::Content.
              update(input[:owner],
                     id: repository.content_id,
                     name: input[:name],
                     contentUrl: content_url,
                     gpgUrl: input[:gpg_key_url] || '', #candlepin ignores nil
                     type: input[:type],
                     arches: input[:arches] || '',
                     requiredTags: input[:os_versions],
                     label: input[:label],
                     metadataExpire: input[:metadata_expire] || 1,
                     vendor: ::Katello::Provider::CUSTOM)

          repository.content.update!(
            name: input[:name],
            content_url: content_url,
            content_type: input[:type],
            label: input[:label],
            gpg_url: input[:gpg_key_url],
            vendor: ::Katello::Provider::CUSTOM
          )
        end
      end
    end
  end
end
