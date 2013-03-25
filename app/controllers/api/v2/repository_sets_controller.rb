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


class Api::V2::RepositorySetsController < Api::V1::RepositorySetsController

  include Api::V2::Rendering

  api :GET, "/product/:product_id/repository_set/", "List repository sets for a product."
  param :organization_id, :identifier, :required => true, :desc => "id of an "
  param :product_id, :number, :required => true, :desc => "id of a product to list repository sets in"
  def index
    raise _('Repository sets are not available for custom products.') if @product.custom?
    respond :collection => @product.productContent
  end

end
