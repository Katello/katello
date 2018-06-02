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
      def substitutions
        {
          :releasever => self.minor,
          :basearch => self.arch
        }
      end

      def content
        Katello::Content.find_by(:cp_content_id => self.content_id, :organization_id => self.product.organization_id)
      end

      def calculate_updated_name
        fail _("Cannot calculate name for custom repos") if custom?
        Katello::Candlepin::RepositoryMapper.new(self.product, self.content, self.substitutions).name
      end

      def should_update_content?
        (self.gpg_key_id_was.nil? && !self.gpg_key_id.nil? && self.content.gpgUrl == '') ||
            (!self.gpg_key_id_was.nil? && self.gpg_key_id.nil? && self.content.gpgUrl != '')
      end

      def yum_gpg_key_url
        # if the repo has a gpg key return a url to access it
        if (gpg_key && gpg_key.content.present?)
          host = Facter.value(:fqdn) || SETTINGS[:fqdn]
          gpg_key_content_api_repository_url(self, :host => host + "/katello", :protocol => 'https')
        end
      end

      def custom_content_label
        "#{organization.label} #{product.label} #{label}".gsub(/\s/, "_")
      end
    end
  end
end
