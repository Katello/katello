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
  module Services
    module PuppetClassImporterExtensions
      extend ActiveSupport::Concern

      included do
        def update_environment(environment)
          change_types = %w(new obsolete updated)
          changed  = self.changes

          change_types.each do |kind|
            changed[kind].slice!(environment.name) unless changed[kind].empty?
          end

          #prevent the puppet environment from being deleted, by removing special '_destroy_' String
          if changed['obsolete'][environment.name]
            changed['obsolete'][environment.name] =
              changed['obsolete'][environment.name].select { |klass| klass != '_destroy_' }
          end

          # PuppetClassImporter expects [kind][env] to be in json format
          change_types.each do |kind|
            unless (envs = changed[kind]).empty?
              envs.keys.sort.each do |env|
                changed[kind][env] = changed[kind][env].to_json
              end
            end
          end

          self.obsolete_and_new(changed)
        end
      end
    end
  end
end
