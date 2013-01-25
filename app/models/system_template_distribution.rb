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

class SystemTemplateDistribution < ActiveRecord::Base
  belongs_to :system_template, :inverse_of => :distributions
  validates_uniqueness_of [:distribution_pulp_id], :scope => :system_template_id, :message => _("is already in the template")
  validates_with Validators::DistributionValidator

  def load_backend_attributes
    @distribution_glue ||= Distribution.find(self.distribution_pulp_id)
    raise Errors::NotFound.new(_("Distribution '%s' was not found in Pulp.") % distribution_pulp_id) if @distribution_glue.nil?
  end

  def description
    load_backend_attributes
    @distribution_glue.description
  end

  def files
    load_backend_attributes
    @distribution_glue.files
  end

  def family
    load_backend_attributes
    @distribution_glue.family
  end

  def variant
    load_backend_attributes
    @distribution_glue.variant
  end

  def version
    load_backend_attributes
    @distribution_glue.version
  end

  def url
    load_backend_attributes
    @distribution_glue.url
  end

  def url_for_environment(env)
    url = @distribution_glue.url
    if url.is_a? Array
      url.find do |u|
        # we relay on the structure of ks url:
        # .../pulp/ks/Org/Env/... to get the env name for the ks URL
        url_env_name = u[/\/pulp\/ks\/[^\/]+\/([^\/]+)/,1]
        url_env_name == env.name
      end
    else
      url
    end
  end

  def arch
    load_backend_attributes
    @distribution_glue.arch
  end
end
