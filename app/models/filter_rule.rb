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

  PACKAGE         = Runcible::Extensions::Rpm.content_type()
  PACKAGE_GROUP   = Runcible::Extensions::PackageGroup.content_type()
  ERRATA          = Runcible::Extensions::Errata.content_type()
  CONTENT_TYPES   = [PACKAGE, PACKAGE_GROUP, ERRATA]
  CONTENT_OPTIONS = {_('Packages') => PACKAGE, _('Package Groups') => PACKAGE_GROUP, _('Errata') => ERRATA}

  validates_inclusion_of :content_type,
                         :in          => CONTENT_TYPES,
                         :allow_blank => false,
                         :message     => "A filter rule must have one of the following types: #{CONTENT_TYPES.join(', ')}."
  def parameters
    write_attribute(:parameters, HashWithIndifferentAccess.new) unless read_attribute(:parameters)
    read_attribute(:parameters)
  end

  def generate_clauses(repo)
    case content_type
      when FilterRule::PACKAGE
        parameters[:units].collect do |unit|
          rule_clauses = []
          if unit[:name] && !unit[:name].blank?
            results = Package.search(unit[:name], 0, 0, [repo.pulp_id],
                            [:nvrea_sort, "ASC"], :all, 'name' ).collect(&:filename)
            unless results.empty?
              rule_clauses << {'filename' => {"$in" => results}}
            end
          end

          if unit.has_key? :version
            rule_clauses << {'version' => unit[:version] }
          else
            vr = {}
            vr["$gte"] = unit[:min_version] if unit.has_key? :min_version
            vr["$lte"] = unit[:max_version] if unit.has_key? :max_version
            rule_clauses << {'version' => vr } unless vr.empty?
          end
          case rule_clauses.size
            when 1
              rule_clauses.first
            when 2
              {'$and' => rule_clauses}
            else
              #ignore
          end
        end.compact

      when FilterRule::PACKAGE_GROUP
        ids = parameters[:units].collect do |unit|
          #{'name' => {"$regex" => unit[:name]}}
          if unit[:name] && !unit[:name].blank?
            PackageGroup.search(unit[:name], 0, 0, [repo.pulp_id]).collect(&:package_group_id)
          end
        end.compact.flatten
        {"id" => {"$in" => ids}}

      when FilterRule::ERRATA
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

          {"id" => {"$in" => ids}}
        else
          if parameters.has_key? :date_range
            date_range = parameters[:date_range]
            dr = {}
            dr["$gte"] = convert_date(date_range[:start]).as_json if date_range.has_key? :start
            dr["$lte"] = convert_date(date_range[:end]).as_json if date_range.has_key? :end
            rule_clauses << {"issued" => dr}
          end
          if parameters.has_key? :errata_type
            unless parameters[:errata_type].empty?
              # {"type": {"$in": ["security", "enhancement", "bugfix"]}
              rule_clauses << {"type" => {"$in" => parameters[:errata_type]}}
            end
          end

          case rule_clauses.size
            when 1
              return rule_clauses.first
            when 2
              return {'$and' => rule_clauses}
            else
              #ignore
          end
        end
      else
        #do nothing
    end
  end
end
