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

require 'rest_client'

class Api::ChangesetsContentController < Api::ApiController

  before_filter :find_changeset

  # TODO: define authorization rules
  skip_before_filter :authorize

  def add_product
    product = @changeset.add_product(params[:product_id])
    @changeset.save!
    render :text => _("Added product '#{product.name}'"), :status => 200
  end

  def remove_product
    @changeset.remove_product(params[:id])
    @changeset.save!
    render :text => _("Removed product '#{params[:id]}'"), :status => 200
  end

  def add_package
    @changeset.add_package(params[:name], params[:product_id])
    @changeset.save!
    render :text => _("Added package '#{params[:name]}'"), :status => 200
  end

  def remove_package
    @changeset.remove_package(params[:id], params[:product_id])
    @changeset.save!
    render :text => _("Removed package '#{params[:id]}'"), :status => 200
  end

  def add_erratum
    @changeset.add_erratum(params[:erratum_id], params[:product_id])
    @changeset.save!
    render :text => _("Added erratum '#{params[:erratum_id]}'"), :status => 200
  end

  def remove_erratum
    @changeset.remove_erratum(params[:id], params[:product_id])
    @changeset.save!
    render :text => _("Removed erratum '#{params[:id]}'"), :status => 200
  end

  def add_repo
    repo = @changeset.add_repo(params[:repository_id], params[:product_id])
    @changeset.save!
    render :text => _("Added repository '#{repo.name}'"), :status => 200
  end

  def remove_repo
    @changeset.remove_repo(params[:id], params[:product_id])
    @changeset.save!
    render :text => _("Removed repository '#{params[:id]}'"), :status => 200
  end

  def add_template
    tpl = @changeset.add_template(params[:template_id])
    @changeset.save!
    render :text => _("Added template '#{tpl.name}'"), :status => 200
  end

  def remove_template
    @changeset.remove_template(params[:id])
    @changeset.save!
    render :text => _("Removed template '#{params[:id]}'"), :status => 200
  end

  def add_distribution
    @changeset.add_distribution(params[:distribution_id], params[:product_id])
    @changeset.save!
    render :text => _("Added distribution '#{params[:distribution_id]}'")
  end

  def remove_distribution
    @changeset.remove_distribution(params[:id], params[:product_id])
    @changeset.save!
    render :text => _("Removed distribution '#{params[:id]}'")
  end

  private

  def find_changeset
    @changeset = Changeset.find(params[:changeset_id])
    raise HttpErrors::NotFound, _("Couldn't find changeset '#{params[:changeset_id]}'") if @changeset.nil?
    @changeset
  end

end
