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

module Util

  class PackageFilter
    FILTER_COLUMNS = { :epoch => :epoch,
                       :version => :sortable_version,
                       :release => :sortable_release
                     }

    attr_accessor :operator, :version, :epoch, :release

    def initialize(evr, operator=nil)
      extract_epoch_version_release(evr)
      self.operator = operator
    end

    def extract_epoch_version_release(evr)
      match = case evr
              when /\A(\d+):(.*)-(.*)\z/
                evr.match(/\A(?<epoch>\d+):(?<version>.*)-(?<release>.*)\z/)
              when /\A(\d+):(.*)\z/
                evr.match(/\A(?<epoch>\d+):(?<version>.*)\z/)
              when /\A(.*)-(.*)\z/
                evr.match(/\A(?<version>.*)-(?<release>.*)\z/)
              else
                evr.match(/\A(?<version>.*)\z/)
              end
      self.version = Package.sortable_version(match[:version])
      self.epoch = match[:epoch] rescue nil
      self.release = (match[:release] rescue nil) ? Package.sortable_version(match[:release]) : nil
    end

    def clauses
      operator == "eq" ? equality_clauses : range_clauses
    end

    private

    def equality_clauses
      [:version, :epoch, :release].each_with_object([]) do |field, clauses|
        clauses << {:term => {field => self.send(field)}} unless self.send(field).blank?
      end
    end

    def range_clauses
      clauses = []

      if epoch
        clauses << range_clause(:epoch, operator, epoch)
        clauses << combo_clause({:epoch => epoch}, :version, operator, version)
        if release
          clauses << combo_clause({:epoch => epoch, :version => version},
                                  :release, operator, release)
        end
      else
        clauses << range_clause(:version, operator, version)
        if release
          clauses << combo_clause({:version => version}, :release, operator, release)
        end
      end

      {:or => clauses}
    end

    def range_clause(field, operator, value)
      {:range => {FILTER_COLUMNS[field] => {operator => value}}}
    end

    def combo_clause(eq_fields, field, operator, value)
      eq_clauses = eq_fields.map do |key, val|
        {:term => {FILTER_COLUMNS[key] => val}}
      end

      {:and => (eq_clauses << range_clause(field, operator, value))}
    end
  end
end
