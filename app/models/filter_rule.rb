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

class FilterRule < ActiveRecord::Base
  belongs_to :filter

  serialize :parameters, HashWithIndifferentAccess
  PACKAGE         = Package::CONTENT_TYPE
  PACKAGE_GROUP   = PackageGroup::CONTENT_TYPE
  ERRATA          = Errata::CONTENT_TYPE
  PUPPET_MODULE   = PuppetModule::CONTENT_TYPE
  CONTENT_TYPES   = [PACKAGE, PACKAGE_GROUP, ERRATA, PUPPET_MODULE]
  YUM_CONTENT_OPTIONS = {_('Packages') => PACKAGE, _('Package Groups') => PACKAGE_GROUP, _('Errata') => ERRATA}
  PUPPET_CONTENT_OPTIONS = {_('Puppet Modules') => PUPPET_MODULE}
  CONTENT_OPTIONS = YUM_CONTENT_OPTIONS.merge(PUPPET_CONTENT_OPTIONS)

  validates_with Validators::SerializedParamsValidator, :attributes => :parameters

  def params_format
    {}
  end

  def parameters
    write_attribute(:parameters, HashWithIndifferentAccess.new) unless read_attribute(:parameters)
    read_attribute(:parameters)
  end

  def content_type
    { PackageRule => PACKAGE,
      ErratumRule => ERRATA,
      PackageGroupRule => PACKAGE_GROUP,
      PuppetModuleRule => PUPPET_MODULE }[self.class]
  end

  def self.class_for( content_type)
    case content_type
    when PACKAGE
      PackageRule
    when PACKAGE_GROUP
      PackageGroupRule
    when ERRATA
      ErratumRule
    when PUPPET_MODULE
      PuppetModuleRule
    else
      params = {:content_type => content_type, :content_types => CONTENT_TYPES.join(", ")}
      raise _("Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}") % params
    end
  end

  def rule_type
    CONTENT_OPTIONS.key(content_type)
  end

  def self.create_for( content_type, options)
    clazz = class_for(content_type)
    clazz.create!(options)
  end

  def as_json(options = {})
    json_val = super(options).update("id" => id,
                                     "content" => content_type,
                                     "type" =>  inclusion ? _("includes"): _("excludes"),
                                     "rule" => parameters)
    json_val.delete("parameters")
    json_val
  end

end
