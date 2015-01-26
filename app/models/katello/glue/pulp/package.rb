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
  module Glue::Pulp::Package
    #fields we use to trim down our unit association calls to pulp
    PULP_SELECT_FIELDS = %w(name epoch version release arch checksumtype checksum)

    PULP_INDEXED_FIELDS = %w(name version release arch suffix epoch
                             download_url checksum checksumtype license group
                             children vendor filename relativepath description
                             size buildhost _id _content_type_id _href
                             _storage_path _type _last_updated)
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        attr_accessor :_id, :download_url, :checksum, :license, :group, :filename, :requires,  :provides, :description,
                      :size, :buildhost, :repoids, :name, :arch, :version, :_content_type_id, :epoch, :vendor, :relativepath,
                      :children, :release, :checksumtype, :files, :changelog

        alias_method 'id=', '_id='
        alias_method 'id', '_id'

        def self.find(id)
          package_attrs = Katello.pulp_server.extensions.rpm.find_by_unit_id(id)
          return if package_attrs.nil?
          Package.new(package_attrs) if package_attrs
        rescue RestClient::ResourceNotFound => exception
          Rails.logger.error "Failed to find pulp package #{id}: #{exception}, #{exception.backtrace.join("\n")}"
          raise exception
        end
      end
    end

    module InstanceMethods
      def initialize(params = {})
        params.delete(:repodata)
        params[:repoids] =  params.delete(:repository_memberships) if params.key?(:repository_memberships)
        params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
      end

      def nvrea
        Util::Package.build_nvrea(self.as_json.with_indifferent_access, false)
      end

      def nvra
        Util::Package.build_nvra(self.as_json.with_indifferent_access)
      end

      def sortable_version
        Util::Package.sortable_version(self.version)
      end

      def sortable_release
        Util::Package.sortable_version(self.release)
      end

      def as_json(options = nil)
        super(options).merge(id: id,
                             sortable_version: sortable_version,
                             sortable_release: sortable_release
                            )
      end
    end
  end
end
