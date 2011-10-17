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

module ActivationKeysHelper

  def no_template
    _("No Template")
  end

  #returns a proc to generate a url for the env_selector
  def url_templates_proc
    lambda{|args|
      system_templates_organization_environment_path(args[:organization].cp_key, args[:environment].id)
    }
  end

  #returns a proc to generate a url for the env_selector
  def url_products_proc
    lambda{|args|
      products_organization_environment_path(args[:organization].cp_key, args[:environment].id)
    }
  end

end
