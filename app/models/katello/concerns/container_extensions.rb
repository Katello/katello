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
  module Concerns
    module ContainerExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :capsule, :inverse_of => :containers, :foreign_key => :capsule_id,
          :class_name => "SmartProxy"
        attr_accessible :capsule_id

        alias_method_chain :repository_pull_url, :katello
      end

      def repository_pull_url_with_katello
        repo_url = repository_pull_url_without_katello

        if self.katello? && self.capsule && Repository.where(:pulp_id => repository_name).count > 0
          "#{URI(self.capsule.url).hostname}:5000/#{repo_url}"
        else
          repo_url
        end
      end
    end
  end
end
