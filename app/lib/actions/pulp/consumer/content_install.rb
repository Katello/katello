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
  module Pulp
    module Consumer
      class ContentInstall < AbstractContentAction
        include Helpers::Presenter
        include Actions::Pulp::ExpectOneTask

        input_format do
          param :consumer_uuid, String
          param :type, %w(rpm package_group erratum)
          param :args, array_of(String)
        end

        def invoke_external_task
          task = pulp_extensions.consumer.install_content(input[:consumer_uuid],
                                                   input[:type],
                                                   input[:args],
                                                    "importkeys" => true)
          schedule_timeout(Setting['content_action_accept_timeout'])
          task
        end

        def presenter
          Consumer::ContentPresenter.new(self)
        end
      end
    end
  end
end
