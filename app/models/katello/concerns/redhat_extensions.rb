# rubocop:disable AccessModifierIndentation
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
  module Concerns
    module RedhatExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :medium_uri, :content_uri
        alias_method_chain :mediumpath, :content
        alias_method_chain :boot_files_uri, :content

        # TODO: these were pulled in from katello_foreman_engine. It may be
        # useful to make them configurable in the future.
        OS = {
            'foreman_os_family' => 'Redhat',
            'foreman_os_rhel_provisioning_template' => 'Katello Kickstart Default for RHEL',
            'foreman_os_provisioning_template' => 'Katello Kickstart Default',
            'foreman_os_pxe_template' => 'Kickstart default PXElinux',
            'foreman_os_ptable' => 'RedHat default'
        }
      end

      module ClassMethods
        def find_or_create_operating_system(distribution)
          os_name = construct_name(distribution.family)
          major, minor = distribution.version.split('.')

          os = ::Redhat.where(:name => os_name, :major => major, :minor => minor).first
          os = create_operating_system(os_name, major, minor) unless os

          return os
        end

        def create_operating_system(name, major, minor)
          params = {
              'name' => name,
              'major' => major.to_s,
              'minor' => minor.to_s,
              'family' => ::Redhat::OS['foreman_os_family']
          }

          provisioning_template_name = if name == 'RedHat'
                                         ::Redhat::OS['foreman_os_rhel_provisioning_template']
                                       else
                                         ::Redhat::OS['foreman_os_provisioning_template']
                                       end

          templates_to_add = [ConfigTemplate.find_by_name(provisioning_template_name),
                              ConfigTemplate.find_by_name(::Redhat::OS['foreman_os_pxe_template'])].compact

          params['os_default_templates_attributes'] = templates_to_add.map do |template|
            {
                "config_template_id" => template.id,
                "template_kind_id" => template.template_kind.id,
            }
          end

          if ptable = Ptable.find_by_name(::Redhat::OS['foreman_os_ptable'])
            params['ptable_ids'] = [ptable.id]
          end

          os = ::Redhat.create!(params)

          templates_to_add.each do |template|
            template.operatingsystems << os
            template.save!
          end

          return os
        end

        def construct_name(family)
          if family.include? 'Red Hat'
            return 'RedHat'
          else
            return family.gsub(' ', '_')
          end
        end

      end

      def medium_uri_with_content_uri(host, url = nil)
        if host.try(:content_source) && (repo_details = kickstart_repo(host))
          URI.parse(repo_details[:path])
        else
          medium_uri_without_content_uri(host, url)
        end
      end

      def mediumpath_with_content(host)
        "url --url #{medium_uri(host)}"
      end

      def kickstart_repo(host)
        distro = distribution_repositories(host).first
        {:name => distro.name, :path => distro.full_path(host.content_source)} if distro && host.content_source
      end

      private

      def distribution_repositories(host)
        content_view = host.environment.content_view
        lifecycle_environment = host.environment.lifecycle_environment

        if content_view && lifecycle_environment
          version = content_view.version(lifecycle_environment)
          repo_ids = version.repositories.in_environment(lifecycle_environment).pluck(:pulp_id)

          #TODO: handle multiple variants
          filters = [{:terms => {:repoids => repo_ids}},
                     {:term => {:version => host.os.release}},
                     {:term => {:arch => host.arch.name}}]
          distributions = Katello::Distribution.search do
            filter :and, filters
          end
          distributions = distributions.select{ |dist| Katello::Distribution.new(dist.as_json).bootable? }
          distribution_repo_ids = distributions.map(&:repoids).flatten

          ::Katello::Repository.where(:pulp_id => (repo_ids & distribution_repo_ids))
        else
          []
        end
      end

      # overwrite foreman method in operatingsystem.rb
      def boot_files_uri_with_content(medium, architecture, host = nil)
        return boot_files_uri_without_content(medium, architecture, host) unless host.try(:content_source)
        family_class = self.family.constantize
        family_class::PXEFILES.values.collect do |img|
          "#{medium_uri(host)}/#{pxedir}/#{img}"
        end
      end

    end
  end
end
