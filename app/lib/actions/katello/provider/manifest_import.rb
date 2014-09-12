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
    module Provider
      class ManifestImport < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(provider, path, force)
          # TODO: extract the REST calls from Provider#import_manifest
          # and construct proper execution plan
          action_subject provider
          plan_self path: path, force: force
        end

        input_format do
          param :provider, Hash do
            param :id
          end
          param :path
          param :force
        end

        def humanized_name
          _("Import Manifest")
        end

        def run
          provider = ::Katello::Provider.find(input[:provider][:id])
          provider.import_manifest(input[:path],
                                   force:  input[:force])
        end
      end
    end
  end
end
