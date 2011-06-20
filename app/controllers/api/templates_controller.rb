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

  before_filter :find_environment, :only => [:create, :import]
  before_filter :find_template, :only => [:show, :update, :update_content, :destroy, :promote, :export]

  def index
    templates = SystemTemplate.where query_params
    render :json => templates.to_json
  end

  def show
    render :json => @template.to_json
  end

  def create
    @template = SystemTemplate.new(params[:template])
    @template.environment = @environment
    @template.save!

    render :json => @template.to_json
  end

  def update
    params[:template].delete(:products_json)
    params[:template].delete(:packages_json)
    params[:template].delete(:errata_json)
    params[:template].delete(:kickstart_attrs_json)
    params[:template].delete(:host_group_json)

    @template.update_attributes!(params[:template])
    render :json => @template
  end

  def update_content

    case params[:do].to_s
      when 'add_product'
        @template.add_product(params[:product])
        @template.save!
        render :text => _("Added product '#{params[:product]}'"), :status => 200 and return

      when 'remove_product'
        @template.remove_product(params[:product])
        @template.save!
        render :text => _("Removed product '#{params[:product]}'"), :status => 200 and return

      when 'add_package'
        @template.add_package(params[:package])
        @template.save!
        render :text => _("Added package '#{params[:package]}'"), :status => 200 and return

      when 'remove_package'
        @template.remove_package(params[:package])
        @template.save!
        render :text => _("Removed package '#{params[:package]}'"), :status => 200 and return

      when 'add_erratum'
        @template.add_erratum(params[:erratum])
        @template.save!
        render :text => _("Added erratum '#{params[:erratum]}'"), :status => 200 and return

      when 'remove_erratum'
        @template.remove_erratum(params[:erratum])
        @template.save!
        render :text => _("Removed erratum '#{params[:erratum]}'"), :status => 200 and return

      when 'add_kickstart_attr'
        @template.kickstart_attrs[params[:attribute]] = params[:value]
        @template.save!
        render :text => _("Added kickstart attribute '#{params[:attribute]}': '#{params[:value]}'"), :status => 200 and return

      when 'remove_kickstart_attr'
        @template.kickstart_attrs.delete(params[:attribute])
        @template.save!
        render :text => _("Removed kickstart attribute '#{params[:attribute]}'"), :status => 200 and return
    end

  end

  def destroy
    @template.destroy
    render :text => _("Deleted system template '#{params[:id]}'"), :status => 200
  end

  def import
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

  def export
    json = @template.string_export
    render :json => json
  end

  def promote
    #TODO: check functionality
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
