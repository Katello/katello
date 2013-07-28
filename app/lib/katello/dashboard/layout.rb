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

module Katello
  module Dashboard
    class Layout

      AVAILABLE_WIDGETS = [
        "subscriptions",
        "notices",
        "content_views",
        "sync",
        "promotions"
      ]

      attr_accessor :widgets, :columns

      def initialize(organization, current_user)
        @widgets = []
        @columns = []
        @organization = organization
        @current_user = current_user

        AVAILABLE_WIDGETS.each do |widget_name|
          widget = get_widget(widget_name, organization)
          @widgets << widget if widget.accessible?
        end
        setup_layout
      end

      def setup_layout
        if (user_layout = current_user.try(:preferences).try(:[], :dashboard).try(:[], :layout))
          user_layout.each do |col|
            @columns << col.map{ |name| get_widget(name, organization) }
          end
        else
          setup_default_layout
        end
      end

      def setup_default_layout
        @columns << Array.new
        @widgets.each_with_index{ |w, i| @columns[0] << w if i.even? }
        @columns << @widgets.select{ |w| !@columns[0].include?(w) }
      end

      def to_hash
        @columns.map { |col| col.map(&:name) }
      end

      def get_widget(name, org)
        "Dashboard::#{name.camelcase}Widget".constantize.new(org)
      end

      def organization
        @organization
      end

      def current_user
        @current_user
      end
    end
  end
end
