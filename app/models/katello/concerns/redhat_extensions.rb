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
    end
  end
end
