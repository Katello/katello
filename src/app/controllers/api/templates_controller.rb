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

class Api::TemplatesController < Api::ApiController

  before_filter :find_environment, :only => [:create]
  before_filter :find_template, :only => [:show, :promote]

  def index
    templates = SystemTemplate.where query_params
    render :json => templates.to_json
  end

  def show
    render :json => @template.to_json
  end

  def create
    begin
      temp_file = File.new(File.join("#{Rails.root}/tmp", "template_#{SecureRandom.hex(10)}.json"), 'w+', 0600)
      temp_file.write params[:template_file].read
    ensure
      temp_file.close
    end

    @template = SystemTemplate.new(params[:template])
    @template.environment = @environment
    @template.import File.expand_path(temp_file.path)
    @template.save!

    render :text => _("Template imported"), :status => 200
  end

  def update
    render :json => "update"
  end

  def destroy
    render :json => "destroy"
  end

  def export
    render :json => "export"
  end

  def promote
    @changeset = Changeset.create!(:environment => @template.environment)

    @changeset.products << @template.products
    @changeset.errata   << changeset_errata(@template.errata)
    @changeset.packages << changeset_packages(@template.packages)
    @changeset.promote



    render :json => "promote"
  end

  def find_environment
    @environment = KPEnvironment.find(params[:environment_id])
    render :text => _("Couldn't find environment '#{params[:environment_id]}'"), :status => 404 and return if @environment.nil?
    @environment
  end

  def find_template
    @template = SystemTemplate.find(params[:id])
    render :text => _("Couldn't find template '#{params[:id]}'"), :status => 404 and return if @template.nil?
    @template
  end

  def changeset_errata(errata)
    errata.collect do |e|
      ChangesetErratum.new(:errata_id=>e.id, :display_name=>e.title, :changeset => @changeset)
    end
  end

  def changeset_packages(packages)
    packages.collect do |p|
      ChangesetPackage.new(:package_id=>p.id, :display_name=>p.name, :changeset => @changeset)
    end
  end

end
