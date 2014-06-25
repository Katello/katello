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
    module HostBaseExtensions
      extend ActiveSupport::Concern

      included do
        has_one :content_host, :class_name => "Katello::System", :foreign_key => :host_id,
                :dependent => :destroy, :inverse_of => :foreman_host
        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hosts
        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source
      end

      def validate_media?
        content_source_id.blank?
      end

     end
  end
end
