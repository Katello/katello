#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module Glue::Candlepin::Content
    def self.included(base)
      base.send :include, InstanceMethods
      # required for GPG key url generation
      base.send :include, Rails.application.routes.url_helpers
    end

    module InstanceMethods
      def content
        return @content unless @content.nil?
        unless self.content_id.nil?
          @content = Katello::Candlepin::Content.find(self.content_id)
        end
        @content
      end

      def create_content
        #only used for custom content
        fail 'Can only create content for custom providers' if self.product.provider.redhat_provider?
        new_content = Candlepin::ProductContent.new(
          :content => {
            :name => self.name,
            :contentUrl => Glue::Pulp::Repos.custom_content_path(self.product, self.label),
            :type => self.content_type,
            :label => self.custom_content_label,
            :vendor => Provider::CUSTOM
          },
          :enabled => true
        )
        new_content.create
        self.product.add_content new_content
        self.content_id = new_content.content.id
        self.cp_label = new_content.content.label
        new_content.content
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
