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
module Dashboard
  class Layout

    AVAILABLE_WIDGETS = %w(
      subscriptions
      subscriptions_totals
      notices
      content_views
      sync
      host_collections
      errata
    )

    attr_accessor :widgets, :columns, :organization, :current_user

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
      if (user_layout = current_user.preferences_hash.try(:[], :dashboard).try(:[], :layout))
        user_layout.each do |col|
          @columns << col.each_with_object([]) do |name, column|
            begin
              widget = get_widget(name, organization)
              column << widget if widget.accessible?
            rescue NameError
              Rails.logger.info("Could not load dashboard widget #{name}")
            end
          end
        end
      else
        setup_default_layout
      end
    end

    def setup_default_layout
      @columns << []
      @widgets.each_with_index{ |w, i| @columns[0] << w if i.even? }
      @columns << @widgets.select{ |w| !@columns[0].include?(w) }
    end

    def to_hash
      @columns.map { |col| col.map(&:name) }
    end

    def get_widget(name, org)
      "Katello::Dashboard::#{name.camelcase}Widget".constantize.new(org)
    end

  end
end
end
