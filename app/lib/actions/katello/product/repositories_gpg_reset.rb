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

module Actions
  module Katello
    module Product
      class RepositoriesGpgReset < Actions::AbstractAsyncTask

        def plan(product)
          key_id = product.gpg_key_id
          # Plan Repository::Update only for repositories which have different gpg key
          product.repositories.each do |repo|
            if repo.gpg_key_id != key_id
              plan_action(::Actions::Katello::Repository::Update,
                          repo,
                          :gpg_key_id => key_id)
            end
          end
        end

      end
    end
  end
end
