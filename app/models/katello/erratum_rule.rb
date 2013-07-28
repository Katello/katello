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

module Katello
  class ErratumRule < FilterRule

    ERRATA_TYPES = {'bugfix' => _('Bug Fix'),
                      'enhancement' => _('Enhancement'),
                      'security' => _('Security')}.with_indifferent_access


    validates_with Validators::ErratumRuleParamsValidator, :attributes => :parameters

    def params_format
      {:units => [[:id]], :date_range => [:start, :end], :errata_type => {}, :severity => {}}
    end

    [:start, :end].each do |date_type|
      define_method("#{date_type}_date") do
        dt = parameters[:date_range].try(:[], date_type)
        Time.at(dt) if dt
      end

      define_method("#{date_type}_date=") do |date|
        parameters[:date_range] ||= {}
        if date
          parameters[:date_range][date_type] = date.to_i
        else
          parameters[:date_range].delete(date_type)
          parameters.delete(:date_range) if parameters[:date_range].empty?
        end
      end
    end

    def errata_types= etypes
      unless etypes.blank?
        parameters[:errata_type] ||= {}
        parameters[:errata_type] = etypes
      else
        parameters.delete(:errata_type)
      end
    end

    def errata_types
      parameters[:errata_type]
    end

    def generate_clauses(repo)
      rule_clauses = []
      if parameters.has_key? :units
        # TODO: WIll add this when we have a proper analyzer for
        # errata_id..
        # ids = parameters[:units].collect do |unit|
        #   if unit[:id] && !unit[:id].blank?
        #     results = Errata.search(unit[:id], 0, 0, [repo.pulp_id], {},
        #                         [:errata_id_sort, "DESC"],'errata_id').collect(&:errata_id)
        #   end
        # end.compact.flatten
        ids = parameters[:units].collect do |unit|
          unit[:id]
        end.compact

        {"id" => {"$in" => ids}}  unless ids.empty?
      else
        if parameters.has_key? :date_range
          dr = {}
          dr["$gte"] = start_date.as_json if start_date
          dr["$lte"] = end_date.as_json if end_date
          rule_clauses << {"issued" => dr}
        end
        if errata_types
            # {"type": {"$in": ["security", "enhancement", "bugfix"]}
          rule_clauses << {"type" => {"$in" => errata_types}}
        end

        if parameters.has_key?(:severity) && !parameters[:severity].empty?
            # {"severity": {"$in": ["low", "moderate", "important", "critical"]}
          rule_clauses << {"severity" => {"$in" => parameters[:severity]}}
        end

        case rule_clauses.size
          when 0
            return
          when 1
            return rule_clauses.first
          else
            return {'$and' => rule_clauses}
        end
      end
    end

    def as_json(options = {})
      params = Util::Support.deep_copy(parameters).with_indifferent_access
      from_date = start_date
      to_date = end_date
      params[:date_range][:start]  = from_date if from_date
      params[:date_range][:end] = to_date if to_date
      json_val = super(options).update("rule" => params)
      json_val.delete("parameters")
      json_val
    end
  end
end
