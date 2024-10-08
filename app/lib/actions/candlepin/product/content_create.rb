module Actions
  module Candlepin
    module Product
      class ContentCreate < Candlepin::Abstract
        input_format do
          param :name
          param :type
          param :arches
          param :label
          param :content_url
          param :owner
          param :os_versions
          param :repository_id
        end

        def run
          content_url = input[:content_url]
          if input[:type] == ::Katello::Repository::DEB_TYPE
            # We must retrieve the deb? repository in the run phase, so the latest Pulp version_href
            # is set. This is needed to retrieve the latest repository.deb_content_url_options!
            repository = ::Katello::Repository.find(input[:repository_id])
            content_url += repository.deb_content_url_options
          end

          output[:response] = ::Katello::Resources::Candlepin::Content.
              create(input[:owner],
                     name: input[:name],
                     contentUrl: content_url,
                     type: input[:type],
                     arches: input[:arches],
                     label: input[:label],
                     requiredTags: input[:os_versions],
                     metadataExpire: 1,
                     vendor: ::Katello::Provider::CUSTOM)
        end
      end
    end
  end
end
