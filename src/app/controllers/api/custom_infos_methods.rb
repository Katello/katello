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

module Api::CustomInfosMethods

  def create_custom_info(informable, params)
    raise HttpErrors::BadRequest, _("A Custom Info keyname must be provided") if params[:keyname].nil?
    raise HttpErrors::BadRequest, _("A Custom Info value must be provided") if params[:value].nil?
    args = params.slice(:keyname, :value)
    new_info = informable.custom_infos.create(args) # keyname and value

    return new_info
  end

  def index_custom_info(informable)
    return consolidate(informable.custom_infos)
  end

  def show_custom_info(informable, params)
    raise HttpErrors::BadRequest, _("A Custom Info keyname must be provided") if params[:keyname].nil?
    return consolidate(informable.custom_infos.where(:keyname => params[:keyname]))
  end

  def update_custom_info(informable, params)
    info_to_update = informable.custom_infos.where(:keyname => params[:keyname], :value => params[:current_value])
    raise HttpErrors::NotFound, _("Couldn't find Custom Info '#{params[:keyname]}: #{params[:current_value]}'") if info_to_update.empty?
    info_to_update.first.update_attributes(:value => params[:value])
    return informable.custom_infos.where(:keyname => params[:keyname], :value => params[:value]).first
  end

=begin
  When all args are supplied (keyname, value), only that one key-value pair will be destroyed.
  If value is nil, then all pairs having keyname will be destroyed.
  If both value and keyname are nil, then all custom info attached to the given informable will be destroyed.
=end
  def destroy_custom_info(informable, params)
    args = params.slice(:keyname, :value)
    unless args.empty?
      return informable.custom_infos.where(args).each { |i| i.destroy }
    else
      return informable.custom_infos.each { |i| i.destroy }
    end
  end

  protected

=begin
  informable.custom_infos returns an array containing a hash for each key-value pair like this:

  [ #<CustomInfo ... keyname: "asset_tag", value: "1234" ... >,
    #<CustomInfo ... keyname: "user", value: "thor" ... >,
    #<CustomInfo ... keyname: "user", value: "loki" ... >,
    #<CustomInfo ... keyname: "user", value: "odin" ... > ]

  consolidate is used to compress the custom info into a single, more manageable hash like this:

  { "asset_tag" => ["1234"],
    "user" => ["thor", "loki", "odin"] }
=end
  def consolidate(infos)
    c = {}
    infos.each do |i|
      k = i[:keyname]
      if c[k].nil?
        c[k] = []
      end
      c[k] << i[:value]
    end
    return c
  end

end