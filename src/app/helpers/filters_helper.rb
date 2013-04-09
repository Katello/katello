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

module FiltersHelper
  include FilterRulesHelper

  # Objectify the record provided. This will generate a hash containing
  # the record id, list of products and list of repos. It assumes that the
  # record has 'products' and 'repositories' relationships.
  def objectify(record)
    repos = Hash.new { |h,k| h[k] = [] }
    record.repositories.each do |repo|
      repos[repo.product.id.to_s] <<  repo.id.to_s
    end

    {
        :id => record.id,
        :products=>record.product_ids,  # :id
        :repos=>repos
    }
  end

  # Retrieve a hash of products that are accessible to the user.
  # This will be determined from the filter record provided in the options.
  def get_products(options)
    if @product_hash.nil?
      @product_hash = {}
      options[:record].content_view_definition.resulting_products.sort_by(&:name).each do |prod|
        @product_hash[prod.id] = {:id => prod.id, :name => prod.name, :editable => true, :repos => []}
      end
      options[:record].content_view_definition.repos.sort_by(&:name).each do |repo|
        @product_hash[repo.product_id][:repos].push({:id => repo.id, :name => repo.name})
      end
    end
    @product_hash
  end

  def filter_rule_url(rule)
    link_to(rule_summary(rule),
            edit_content_view_definition_filter_rule_path(rule.filter.content_view_definition.id,
                                                          rule.filter.id, rule.id))
  end

  def rule_summary(rule)
    if rule.content_type == FilterRule::PACKAGE || rule.content_type == FilterRule::PACKAGE_GROUP
      # Create a package or package group list summary
      summary = parameter_list_summary(rule, :name)

    elsif rule.content_type == FilterRule::ERRATA
      # If this rule has either errata type or date range parameters,
      # create a date summary; otherwise, create an errata list summary
      if !rule.parameters[:errata_type].blank? || (!rule.parameters[:date_range].blank? &&
          (!rule.parameters[:date_range][:start].blank? || !rule.parameters[:date_range][:end].blank?))
        summary = errata_type_date_summary(rule)
      else
        summary = parameter_list_summary(rule, :id)
      end
    end
    summary
  end

  def rule_inclusion(rule)
    rule.inclusion? ? _('Include') : _('Exclude')
  end

  def parameter_list_summary(rule, field)
    parameter_list = rule.parameters[:units].collect{|p| p[field]} unless rule.parameters[:units].blank?

    parameter_list = parameter_list.blank? ? _('No details specified') : parameter_list.join(', ')

    _("%{include} %{rule_type}: %{parameter_list}") %
        {:include => rule_inclusion(rule),
         :rule_type => FilterRule::CONTENT_OPTIONS.index(rule.content_type),
         :parameter_list => parameter_list}
  end

  def errata_type_date_summary(rule)
    if (errata_types = selected_errata_types(rule)).blank?
      errata_types = _('All types')
    end

    date_summary = ""
    if !rule.parameters[:date_range].blank?
      if rule.start_date || rule.end_date
        start_date = rule.start_date.to_date
        end_date = rule.end_date.to_date

        if start_date.blank?
          date_summary = _("Before %{end_date}") % {:end_date => end_date}
        elsif end_date.blank?
          date_summary = _("After %{start_date}") % {:start_date =>start_date}
        else
          date_summary = _("%{start_date} - %{end_date}") % {:start_date => start_date,
                                                            :end_date => end_date}
        end
      end
      date_summary = _("Any date") if date_summary.blank?
    end

    _("%{include} %{rule_type}: %{errata_types}: %{date_summary}") %
        {:include => rule_inclusion(rule),
         :rule_type => FilterRule::CONTENT_OPTIONS.index(rule.content_type),
         :errata_types => errata_types,
         :date_summary => date_summary}
  end
end
