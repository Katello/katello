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
  module Glue::Pulp::DockerImage
    extend ActiveSupport::Concern

    def initialize(params = {})
      params['repoids'] = params.delete(:repository_memberships) if params.key?(:repository_memberships)
      params.each_pair {|k, v| instance_variable_set("@#{k}", v) unless v.nil? }
      self.id ||= _id
    end

    included do
      attr_accessor :image_id, :tags, :_storage_path, :_ns, :id, :_id, :parent_id,
        :size, :repoids
    end

    module ClassMethods
      def find(id, repo_id = nil)
        attrs = Katello.pulp_server.extensions.docker_image.find_by_unit_id(id)
        attrs["tags"] = get_tags(repo_id, attrs[:image_id]) if repo_id && attrs[:image_id]

        Katello::DockerImage.new(attrs) if attrs
      end

      def find_all(repo_id)
        images = find_all_without_tags(repo_id)
        fill_tags(images, repo_id)
      end

      def get_tags(repo_id, image_id)
        repo_attrs = Katello.pulp_server.extensions.repository.retrieve_with_details(repo_id)
        return unless repo_attrs.try(:[], :scratchpad).try(:[], :tags)

        repo_attrs[:scratchpad][:tags].select { |tag| tag[:image_id] == image_id }.map { |tags| tags[:tag] }
      end

      def fill_tags(images, repo_id)
        repo_attrs = Katello.pulp_server.extensions.repository.retrieve_with_details(repo_id)
        return images unless repo_attrs.try(:[], :scratchpad).try(:[], :tags)

        images.each { |image| image.tags = [] }.tap do |imgs|
          repo_attrs[:scratchpad][:tags].each do |tag|
            imgs.each do |image|
              image.tags << tag[:tag] if tag[:image_id] == image.image_id
            end
          end
        end
      end

      def find_all_without_tags(repo_id)
        ids = Katello.pulp_server.extensions.repository.docker_image_ids(repo_id)
        images_data = []

        ids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
          images_data.concat(Katello.pulp_server.extensions.docker_image.find_all_by_unit_ids(sub_list))
        end

        images_data.map { |attrs| Katello::DockerImage.new(attrs) }
      end
    end
  end
end
