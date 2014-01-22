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
    module MediumExtensions
      extend ActiveSupport::Concern

      module ClassMethods

        def update_media(repo)
          return if repo.puppet?

          medium_path = Medium.installation_media_path(repo.uri)

          if distribution = repo.bootable_distribution
            return if Medium.find_by_path(medium_path)

            os = Operatingsystem.find_or_create_operating_system(distribution)

            arch = Architecture.where(:name => distribution.arch).first_or_create!
            os.architectures << arch unless os.architectures.include?(arch)

            medium_name = Medium.construct_name(repo, distribution)
            medium = Medium.create!(:name => medium_name, :path => medium_path,
                                    :os_family => Operatingsystem::OS['foreman_os_family'],
                                    :organization_ids => [repo.organization.id])
            os.media << medium
            os.save!

          else
            if medium = Medium.find_by_path(medium_path)
              medium.destroy
            end
          end

        end

        def construct_name(repo, distribution)
          parts = [repo.organization.label, repo.environment.label]
          if repo.content_view && !repo.content_view.default?
            parts << repo.content_view.label
          end
          parts = [parts.compact.join('/')]

          parts << distribution.family
          parts << distribution.variant
          parts << distribution.version
          parts << distribution.arch

          name = parts.reject(&:blank?).join(' ')
          return normalize_name(name)
        end

        # Foreman and Puppet uses RedHat name for Red Hat Enterprise Linux
        def normalize_name(name)
          name.sub('Red Hat Enterprise Linux', 'RedHat')
        end

        # takes repo uri from Katello and makes installation media url
        # suitable for provisioning from it
        def installation_media_path(repo_uri)
          path = repo_uri.sub(/\Ahttps/, 'http')
          path << "/" unless path.end_with?('/')
          return path
        end
      end
    end
  end
end
