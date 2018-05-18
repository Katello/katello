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
      def should_update_content?
        (self.gpg_key_id_was.nil? && !self.gpg_key_id.nil? && self.content.gpgUrl == '') ||
            (!self.gpg_key_id_was.nil? && self.gpg_key_id.nil? && self.content.gpgUrl != '')
      end

      def yum_gpg_key_url
        # if the repo has a gpg key return a url to access it
        if (gpg_key && gpg_key.content.present?)
          host = SETTINGS[:fqdn]
          gpg_key_content_api_repository_url(self, :host => host + "/katello", :protocol => 'https')
        end
      end

      def custom_content_label
        "#{organization.label} #{product.label} #{label}".gsub(/\s/, "_")
      end
    end
  end
end
