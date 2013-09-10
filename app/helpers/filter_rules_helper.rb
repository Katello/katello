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

module FilterRulesHelper
  def errata_types
    ErratumRule::ERRATA_TYPES
  end

  def selected_errata_types(rule)
    # get a comma-separated list of the errata types currently selected
    rule.parameters[:errata_type].map{|type| errata_types[type]}.join(', ') if rule.parameters[:errata_type]
  end

  def included_text(rule)
    rule.inclusion? ? _("Include") : _("Exclude")
  end

  def version_options
    {
        _('All Versions') => 'all_versions',
        _('Only Version') => 'version',
        _('Newer Than') => 'min_version',
        _('Older Than') => 'max_version',
        _('Range') => 'version_range'
    }
  end

  def version_selector_readonly(rule, unit)
    version_selected = version_selected(unit)
    value1, value2 = version_values(unit)

    version_options.key(version_selected) +
        (value1.blank? ? '' : ' ' + value1.to_s) +
        (value2.blank? ? '' : ' - ' + value2.to_s)
  end

  def version_selected(unit)
    if !unit[:version].blank?
      'version'
    elsif !unit[:min_version].blank? && !unit[:max_version].blank?
      'version_range'
    elsif !unit[:max_version].blank?
      'max_version'
    elsif !unit[:min_version].blank?
      'min_version'
    else
      'all_versions'
    end
  end

  def version_values(unit)
    if !unit[:version].blank?
      value1 = unit[:version]
    elsif !unit[:min_version].blank? && !unit[:max_version].blank?
      value1 = unit[:min_version]
      value2 = unit[:max_version]
    elsif !unit[:max_version].blank?
      value1 = unit[:max_version]
    elsif !unit[:min_version].blank?
      value1 = unit[:min_version]
    end

    return value1, value2
  end

  def content_options(filter)
    repos = filter.repos(current_organization.library)
    options = {}
    if repos.select(&:yum?).length > 0
      options.merge!(FilterRule::YUM_CONTENT_OPTIONS)
    end
    if repos.select(&:puppet?).length > 0
      options.merge!(FilterRule::PUPPET_CONTENT_OPTIONS)
    end
    options_for_select(options)
  end

end
