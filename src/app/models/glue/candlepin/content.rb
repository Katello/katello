#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


module Glue::Candlepin::Content
  def self.included(base)
    base.send :include, InstanceMethods
    # required for GPG key url generation
    base.send :include, Rails.application.routes.url_helpers

    base.class_eval do
      before_save :save_content_orchestration
      before_destroy :destroy_content_orchestration
    end
  end

  module InstanceMethods
    def destroy_content_orchestration
      pre_queue.create(:name => "remove content : #{self.name}", :priority => 2, :action => [self, :del_content])
    end

    def save_content_orchestration
      return if self.new_record?  #don't try to refresh on create
      pre_queue.create(:name => "update content : #{self.name}", :priority => 2, :action => [self, :update_content])
    end

    def del_content
      return true unless self.content_id
      if other_repos_with_same_product_and_content.empty?
        self.product.remove_content_by_id self.content_id
        if other_repos_with_same_content.empty? && !self.product.provider.redhat_provider?
          Resources::Candlepin::Content.destroy(self.content_id)
        end
      end

      true
    end

    # TODO: UGH. This calls methods from Glue::Pulp::Repo.
    def content
      return @content unless @content.nil?
      unless self.content_id.nil?
        @content = ::Candlepin::Content.find(self.content_id)
      end
      @content
    end

    def update_content
      #if the gpg key was enabled
      #we only update the content if the content is actually not set properly
      #this means we don't recreate the environment for the same repo in
      #each environment.   We do the same for it being disabled, we check
      #to make sure it is not enabled in the contnet before refreshing
      if should_update_content?
        self.content.update({
          :name => self.name,
          :contentUrl => Glue::Pulp::Repos.custom_content_path(self.product, label),
          :gpgUrl => yum_gpg_key_url,
          :label => custom_content_label,
          :type => "yum",
          :vendor => Provider::CUSTOM
        })
      else
        true # required, or orchestration engine will think that update failed.
      end
    end

    def should_update_content?
      (self.gpg_key_id_was == nil && self.gpg_key_id != nil && self.content.gpgUrl == '') ||
          (self.gpg_key_id_was != nil && self.gpg_key_id == nil && self.content.gpgUrl != '')
    end

    def yum_gpg_key_url
      # if the repo has a gpg key return a url to access it
      if (gpg_key && gpg_key.content.present?)
        host = Katello.config.host
        host += ":" + Katello.config.port.to_s unless Katello.config.port.blank? || Katello.config.port.to_s == "443"
        gpg_key_content_api_repository_url(self, :host => host + Katello.config.url_prefix, :protocol => 'https')
      end
    end

    def custom_content_label
      "#{organization.label} #{product.label} #{label}".gsub(/\s/,"_")
    end
  end

end
