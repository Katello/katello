#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module AutoCompleteSearch
  include SearchHelper

  def auto_complete_search
    begin
      query = "#{params[:search]}"
      @items = eval(controller_name.singularize.camelize).complete_for(params[:search])
      @items = @items.map do |item|
        category = (['and','or','not','has'].include?(item.to_s.sub(/^.*\s+/,''))) ? 'Operators' : ''
        {:label => item, :category => category}
      end
      @items = [query] if @items.blank?
    rescue ScopedSearch::QueryNotSupported => e
       @items = [{:error =>e.to_s}]
    end
    render :json => @items
  end
end
