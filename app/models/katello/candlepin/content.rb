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
  class Candlepin::Content
    # rubocop:disable SymbolName
    attr_accessor :name, :id, :type, :label, :vendor, :contentUrl, :gpgUrl

    def initialize(params = {})
      load_attributes(params)
    end

    def self.find(id)
      found = Resources::Candlepin::Content.get(id)
      Candlepin::Content.new(found)
    end

    def create
      created = Resources::Candlepin::Content.create self
      load_attributes(created)

      self
    end

    def destroy
      Resources::Candlepin::Content.destroy(@id)
    end

    def update(params = {})
      return self if params.empty?

      updated = Resources::Candlepin::Content.update(params.merge(:id => @id))
      load_attributes(updated)

      self
    end

    def load_attributes(params)
      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    class RepositoryMapper
      attr_reader :product, :content, :substitutions

      def initialize(product, content, substitutions)
        @product = product
        @content = content
        @substitutions = substitutions
      end

      def find_repository
        ::Katello::Repository.where(product_id: product.id,
                                    environment_id: product.organization.library.id,
                                    pulp_id: pulp_id).first
      end

      def build_repository
        repository = ::Katello::Repository.new(:environment => product.organization.library,
                                               :product => product,
                                               :pulp_id => pulp_id,
                                               :cp_label => content.label,
                                               :content_id => content.id,
                                               :arch => arch,
                                               :major => major,
                                               :minor => minor,
                                               :relative_path => relative_path,
                                               :name => name,
                                               :label => label,
                                               :url => feed_url,
                                               :feed_ca => ca,
                                               :feed_cert => product.certificate,
                                               :feed_key => product.key,
                                               :content_type => katello_content_type,
                                               :preserve_metadata => true, #preserve repo metadata when importing from cp
                                               :unprotected => unprotected?,
                                               :content_view_version => product.organization.library.default_content_view_version)

        repository.docker_upstream_name = self.name if repository.docker?
        repository
      end

      def check_substitutions!
        unless content_type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
          if substitutor.valid_substitutions?(content.contentUrl, substitutions)
            return true
          else
            fail _("%{substitutions} are not valid substitutions for %{content_url}") %
                { substitutions: substitutions, content_url: content.contentUrl }
          end
        end
      end

      def substitutor
        product.cdn_resource.substitutor
      end

      def name
        sorted_substitutions = substitutions.sort_by { |k, _| k.to_s }.map(&:last)
        repo_name_parts = [content.name,
                           sorted_substitutions].flatten.compact
        repo_name_parts.join(" ").gsub(/[^a-z0-9\-\._ ]/i, "")
      end

      def pulp_id
        product.repo_id(name)
      end

      def path
        substitutions.inject(content.contentUrl) do |url, (key, value)|
          url.gsub("$#{key}", value)
        end
      end

      def relative_path
        ::Katello::Glue::Pulp::Repos.repo_path_from_content_path(product.organization.library, path)
      end

      def feed_url
        product.repo_url(path, content_type)
      end

      def arch
        substitutions[:basearch] || "noarch"
      end

      def label
        ::Katello::Util::Model.labelize(name)
      end

      def version
        ::Katello::Resources::CDN::Utils.parse_version(substitutions[:releasever])
      end

      def major
        version[:major]
      end

      def minor
        version[:minor]
      end

      def content_type
        kickstart? ? 'yum' : content.type
      end

      def katello_content_type
        if content_type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
          ::Katello::Repository::DOCKER_TYPE
        else
          content_type
        end
      end

      def unprotected?
        kickstart? ? true : false
      end

      def kickstart?
        content.type.downcase == 'kickstart'
      end

      def ca
        File.read(::Katello::Resources::CDN::CdnResource.ca_file)
      end
    end
  end
end
