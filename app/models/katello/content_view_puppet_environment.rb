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
  class ContentViewPuppetEnvironment < Katello::Model
    self.include_root_in_json = false

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Pulp::Repo if Katello.config.use_pulp
    include Glue::ElasticSearch::ContentViewPuppetEnvironment if Katello.config.use_elasticsearch
    include Glue if Katello.config.use_pulp

    belongs_to :environment, :class_name => "Katello::KTEnvironment",
                             :inverse_of => :content_view_puppet_environments
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
                                      :inverse_of => :content_view_puppet_environments

    belongs_to :puppet_environment, :class_name => "Environment",
                                    :inverse_of => :content_view_puppet_environment, :dependent => :destroy

    validates_lengths_from_database
    validates :pulp_id, :presence => true, :uniqueness => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates :puppet_environment_id, :presence => true, :if => :environment

    scope :non_archived, where('environment_id is not NULL')
    scope :archived, where('environment_id is NULL')

    def content_type
      Repository::PUPPET_TYPE
    end

    def puppet?
      true
    end

    def organization
      if self.environment
        self.environment.organization
      else
        self.content_view.organization
      end
    end

    def content_view
      self.content_view_version.content_view
    end

    def self.in_content_view(view_id)
      joins(:content_view_version).where(
          "#{Katello::ContentViewVersion.table_name}.content_view_id" => view_id)
    end

    def self.in_environment(env_id)
      where(environment_id: env_id)
    end

    def archive?
      self.environment.nil?
    end

    def generate_puppet_path
      # rubocop:disable Style/EmptyElse
      if self.environment
        File.join(Katello.config.puppet_repo_root, generate_puppet_env_name, 'modules')
      else
        nil #don't generate archived content view puppet environments
      end
    end

    def generate_puppet_env_name
      if self.environment
        Environment.construct_name(self.organization,
                                   self.environment,
                                   self.content_view)
      end
    end

    def self.generate_pulp_id(organization_label, env_label, view_label, version)
      [organization_label, env_label, view_label, version].compact.join("-").gsub(/[^-\w]/, "_")
    end
  end
end
