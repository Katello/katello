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

# various user-configurable mappings defined in /etc/katello/mapping.yml

require 'yaml'

module Mapping

  def self.configuration
    @config ||= YAML.load_file('/etc/katello/mapping.yml')
  end

  class ImageFactoryNaming

    def self.translate(name = '', version = '')
      naming = Mapping.configuration['imagefactory_naming']
      naming["#{name} #{version}"].map(&:to_s)
    rescue Exception => e
      [name.to_s, version.to_s]
    end

  end

end
