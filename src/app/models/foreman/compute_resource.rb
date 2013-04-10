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

class Foreman::ComputeResource < Resources::ForemanModel

  PROVIDERS = %w[ Libvirt Ovirt EC2 Vmware Openstack Rackspace ]

  attributes :name, :url, :description, :provider, :created_at, :updated_at
  validates_presence_of :name, :url

  def json_attributes
    not_nil_attrs = attributes.keys.delete_if { |attr| send(attr).nil? }
    { :only => not_nil_attrs }
  end

  def json_default_options
    return {
      :only   => json_attributes,
      :root   => :compute_resource,
      :except => [:password]
    }
  end


  # allows to create a specific compute class based on the provider
  def self.new_provider(args)
    return self.resource_class(args).new(args)
  end

  def self.resource_class(args)
    raise "Must provide a provider." unless provider = args.try(:[], :provider)
    PROVIDERS.each do |p|
      return "::Foreman::ComputeResource::#{p}".constantize if p.downcase == provider.downcase
    end
    raise _("Unknown provider type. Choose one of: %s") % PROVIDERS.join(", ")
  end


end
