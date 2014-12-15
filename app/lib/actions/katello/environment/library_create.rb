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
    module Environment
      class LibraryCreate < Actions::Base
        def plan(library_env)
          library_env.save!
          library_view = ::Katello::ContentView.create!(:default => true,
                                                        :name => "Default Organization View",
                                                        :organization => library_env.organization)

          ::Katello::ContentViewVersion.create! do |v|
            v.content_view = library_view
            v.major = 1
          end

          version = library_view.versions.first

          plan_action(Katello::ContentView::Create, library_view)
          plan_action(Katello::ContentView::AddToEnvironment, version, library_env)
          plan_action(Katello::Foreman::ContentUpdate, library_env, library_view)
        end

        def humanized_name
          _("Create")
        end

        input_format do
          param :name, String
          param :label, String
          param :organization_label, String
        end
      end
    end
  end
end
