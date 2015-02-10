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
    module Containers
      module StepsControllerExtensions
        extend ActiveSupport::Concern
        included do
          alias_method_chain :set_form, :katello
          alias_method_chain :build_state, :katello
        end

        def set_form_with_katello
          if step == :image && @state.image.nil?
            @docker_container_wizard_states_image = @state.build_image(:katello => true)
          else
            set_form_without_katello
          end
        end

        def build_state_with_katello
          if step == :image && params.key?(:katello)
            repo = nil
            tag = nil
            capsule_id = nil
            if params[:repository] && params[:repository][:id]
              repo = Repository.where(:id => params[:repository][:id]).first
            end

            if params[:tag] && params[:tag][:id]
              tag = DockerTag.where(:id => params[:tag][:id]).first
            end
            if params[:capsule] && params[:capsule][:id]
              capsule_id = params[:capsule][:id]
            end
            @docker_container_wizard_states_image = @state.build_image(:repository_name => repo.try(:pulp_id),
                                :tag => tag.try(:name),
                                :capsule_id => capsule_id,
                                :katello => true)
          else
            build_state_without_katello
          end
        end
      end
    end
  end
end
