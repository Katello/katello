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

module Glue::Pulp::PuppetModule

  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do
      attr_accessor :_storage_path, :tag_list, :description, :license, :author,
                    :_ns, :project_page, :summary, :source, :dependencies, :version,
                    :_content_type_id, :checksums, :_id, :types, :name, :repoids

      alias_method 'id=', '_id='
      alias_method 'id', '_id'

      def self.find(id)
        attrs = Katello.pulp_server.extensions.puppet_module.find_by_unit_id(id)
        ::PuppetModule.new(attrs) if !attrs.nil?
      end
    end

  end

  module InstanceMethods
    def initialize(params = {}, options={})
      params['repoids'] = params.delete(:repository_memberships) if params.has_key?(:repository_memberships)
      params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def sortable_version
      Util::Package.sortable_version(self.version)
    end

    def as_json(options = nil)
      super(options).merge(sortable_version: sortable_version)
    end
  end

end
