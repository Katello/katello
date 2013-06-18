#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'set'

module Glue::Candlepin::Environment

  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do
      before_save :save_environment_orchestration
      before_destroy :destroy_environment_orchestration
    end
  end

  module InstanceMethods

    def set_environment
      Resources::Candlepin::Environment.find(self.cp_id)
      Rails.logger.info _("Candlepin environment already exists: %s") % self.cp_id
      true
    rescue RestClient::ResourceNotFound => e
      Rails.logger.info _("Creating environment in candlepin: %s") % self.label
      Resources::Candlepin::Environment.create(self.content_view.organization.label, self.cp_id, self.label,
                                               self.content_view.description)
      true
    rescue => e
      Rails.logger.error _("Failed to create candlepin environment %s") %
                           "#{self.label}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_environment
      Rails.logger.info _("Deleting environment in candlepin: %s") % self.label
      Resources::Candlepin::Environment.destroy(self.cp_id)
      true
    rescue RestClient::ResourceNotFound => e
      Rails.logger.info _("Candlepin environment doesn't exist: %s") % self.label
      true
    rescue => e
      Rails.logger.error _("Failed to delete candlepin environment %s") %
                           "#{self.label}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_environment_orchestration
      case self.orchestration_for
        when :create
          post_queue.create(:name => "candlepin environment for content view: #{self.content_view.label}",
                            :priority => 3,
                            :action => [self, :set_environment])
      end
    end

    def destroy_environment_orchestration
      post_queue.create(:name => "candlepin environment for content view: #{self.content_view.label}",
                        :priority => 4,
                        :action => [self, :del_environment])
    end

    def update_cp_content
      all_env_ids = all_env_content_ids
      saved_cp_ids = saved_env_content_ids

      add_ids = all_env_ids - saved_cp_ids
      Resources::Candlepin::Environment.add_content(self.cp_id, add_ids) unless add_ids.empty?

      delete_ids = saved_cp_ids - all_env_ids.to_a
      Resources::Candlepin::Environment.delete_content(self.cp_id, delete_ids) unless delete_ids.empty?
    end

    protected

    def all_env_content_ids
      self.content_view.repos(self.owner).select{|r| r.enabled}.reduce(Set.new) do |env_content_ids, repo|
        env_content_ids << repo.content_id
      end
    end

    def saved_env_content_ids
      Resources::Candlepin::Environment.find(self.cp_id)[:environmentContent].map do |content|
        content[:contentId]
      end
    end

  end

end
