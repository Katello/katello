module Katello
  module Glue::Candlepin::Repository
    CANDLEPIN_DOCKER_TYPE = "containerimage".freeze
    CANDLEPIN_OSTREE_TYPE = "ostree".freeze

    def self.included(base)
      base.send :include, InstanceMethods
      # required for GPG key url generation
      base.send :include, Rails.application.routes.url_helpers
    end

    module InstanceMethods
      def content
        Katello::Content.find_by(:cp_content_id => self.content_id, :organization_id => self.product.organization_id)
      end

      def yum_gpg_key_url
        # if the repo has a gpg key return a url to access it
        if (gpg_key && gpg_key.content.present?)
          host = SETTINGS[:fqdn]
          gpg_key_content_api_repository_url(self, :host => host + "/katello", :protocol => 'https')
        end
      end
    end
  end
end
