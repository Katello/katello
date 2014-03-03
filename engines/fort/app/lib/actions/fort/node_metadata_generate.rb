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

module Actions
  module Fort
    class NodeMetadataGenerate < ::Actions::Pulp::Abstract

      def self.subscribe
        Actions::Katello::Repository::NodeMetadataGenerate
      end

      def run
        repo = ::Katello::Repository.find(input['id'])
        if repo.environment
          Node.with_environment(repo.environment).each do |node|
            node.sync(:repository => repo)
          end
        end
      end

    end

  end

end
