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
      Rails.logger.info _("Creating an environment in candlepin: %s") % label
      Resources::Candlepin::Environment.create(self.organization.label, id, label, description)
    rescue => e
      Rails.logger.error _("Failed to create candlepin environment %s") % "#{label}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_environment
      Rails.logger.info _("Deleting environment in candlepin: %s") % label
      Resources::Candlepin::Environment.destroy(id)
    rescue => e
      Rails.logger.error _("Failed to delete candlepin environment %s") % "#{label}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_environment_orchestration
      case self.orchestration_for
        when :create
          post_queue.create(:name => "candlepin environment for organization: #{self.label}", :priority => 3, :action => [self, :set_environment])
      end
    end

    def destroy_environment_orchestration
      post_queue.create(:name => "candlepin environment for organization: #{self.label}", :priority => 4, :action => [self, :del_environment])
    end


    # the name of the method is misleading - it's not update of content, but rather promotion of content to environment
    def update_cp_content
      new_content_ids = all_env_content_ids - saved_env_content_ids
      Resources::Candlepin::Environment.add_content(self.id, new_content_ids)
    end

    protected

    def all_env_content_ids
      #can't use enabled scope due to intermittent issue
      self.repositories.all.select{|r| r.enabled}.reduce(Set.new) do |env_content_ids, repo|
        env_content_ids << repo.content_id
      end
    end

    def saved_env_content_ids
      Resources::Candlepin::Environment.find(self.id)[:environmentContent].map do |content|
        content[:contentId]
      end
    end


  end

end
