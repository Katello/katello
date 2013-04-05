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

class Foreman::ConfigTemplate < Resources::ForemanModel

  attributes :name, :template, :snippet, :audit_comment, :kind, :kind_id,
    :template_kind_id, :template_combinations_attributes, :operatingsystem_ids

  def json_default_options
    { :only => [:name, :template, :snippet, :audit_comment, :kind, :kind_id,
                :template_combinations_attributes, :operatingsystem_ids] }
  end

  def json_create_options
    { :only => [:name, :template, :snippet, :audit_comment],
      :methods => [:template_kind_id] }
  end

  def json_update_options
    json_create_options
  end

  def template_kind_id
    @kind_id
  end

  def template_kind_id=(kind_id)
    @kind_id = kind_id
  end

  def self.revision(audit_id)
    resource.revision({:version => audit_id}, header).first
  end

  def self.build_pxe_default
    resource.build_pxe_default({}, header).first
  end
end
