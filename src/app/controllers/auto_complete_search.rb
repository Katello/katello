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

      # a filter may be optionally defined by the calling controller... the filter can be used to ensure that
      # auto complete only returns results that are applicable to the user performing the search...
      # if a filter is provided, use it...
      # an example filter could be something like: {:organization_id => current_organization}
      @filter = {} if @filter.nil?

      # scoped_search provides the ability to pass a filter parameter in the request... on pages that have the
      # environment selector, we use this filter to communicate which environment the results should be provided for...
      if !params[:filter].nil? and eval(controller_name.singularize.camelize).respond_to?('by_env')
        @items = eval(controller_name.singularize.camelize).readable(current_organization).by_env(params[:filter]).complete_for(params[:search], @filter)
      else
        if (controller_name == "notices")
          @items = eval(controller_name.singularize.camelize).readable(current_user).complete_for(params[:search], @filter)
        else
          @items = eval(controller_name.singularize.camelize).readable(current_organization).complete_for(params[:search], @filter)
        end
      end

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
