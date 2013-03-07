#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Foreman::TemplateCombination < Resources::ForemanModel
  attributes :id, :environment_id, :hostgroup_id, :config_template_id

  def json_default_options
    { :only => [:id, :environment_id, :hostgroup_id, :config_template_id] }
  end

  def json_create_options
    { :only => [:environment_id, :hostgroup_id] }
  end

  # FIXME: need propert support for sub-resources.
  def as_json(options = {})
    return super(options).merge('config_template_id' => config_template_id)
  end
end
