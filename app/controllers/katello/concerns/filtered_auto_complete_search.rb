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
    module FilteredAutoCompleteSearch
      extend ActiveSupport::Concern

      def auto_complete_search
        begin
          options = resource_class.respond_to?(:completer_scope_options) ? resource_class.completer_scope_options : {}
          items = self.index_relation.complete_for(params[:search], options)
          items = items.map do |item|
            category = (['and', 'or', 'not', 'has'].include?(item.to_s.sub(/^.*\s+/, ''))) ? _('Operators') : ''
            part = item.to_s.sub(/^.*\b(and|or)\b/i) { |match| match.sub(/^.*\s+/, '') }
            completed = item.to_s.chomp(part)
            {:completed => CGI.escapeHTML(completed), :part => CGI.escapeHTML(part), :label => item, :category => category}
          end
        rescue ScopedSearch::QueryNotSupported => e
          items = [{:error => e.to_s}]
        end
        render :json => items
      end
    end
  end
end
