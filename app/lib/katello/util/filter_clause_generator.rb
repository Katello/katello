#
# Copyright 2014 Red Hat, Inc.
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
  module Util
    module FilterClauseGenerator

      def initialize(repo, filters)
        @repo = repo
        @filters = filters
      end

      def generate
        @whitelist = clauses_for(:whitelist)
        @blacklist = clauses_for(:blacklist)
      end

      # This is used to generate copy clauses
      # during the "publish" of a content view definition
      # Generates clause in the following format
      # {$and => [
      #      {$or => [<whitelist clauses>]},
      #      {$nor => [{$or => [<blacklist clauses>]}]}
      # ]}
      def copy_clause
        clauses = []
        whitelist = join_clauses(@whitelist, "$or")
        blacklist = !@blacklist.blank?  ? {"$nor" => @blacklist} : nil

        clauses << whitelist  if whitelist
        clauses << blacklist  if blacklist
        join_clauses(clauses, "$and")
      end

      # This is used to generate unassociation clauses
      # during the "publish" of a content view definition
      # Generates clause in the following format
      # { $or => [<blacklist clauses>]}}
      def remove_clause
        join_clauses(@blacklist, "$or")
      end

      protected

      def join_clauses(clauses, join_by)
        return nil if clauses.blank?
        if clauses.size > 1
          {join_by => clauses}
        elsif clauses.size == 1
          clauses.first
        end
      end

      def clauses_for(list_type)
        # fetch the applicable content type filters - fetch_filters implemented
        # by subclasses. idea is those content type  filter classes would
        # implement whitelist, blacklist scopes.
        filters = fetch_filters.send(list_type).where(:id => @filters) # abstract
        if filters.any?
          # generate the clauses from filters to be implemented by subclasses
          clauses = collect_clauses(@repo, filters) # abstract
          clauses.delete_if {|cls| cls.blank?}
          if clauses.any?
            clauses
          elsif list_type == :whitelist
            # whitelist rules were provided
            # but they generated no clause due to the fact
            # that there were no matches. So we need
            # a white list non matching mongo clause
            # something like => {"unit_id" => {"$not" => {"$exists" => true}}}
            # meaning "do not copy any unit has an id"
            # We need this to not make the "copy" happen if whitelists had no items to copy.
            # example scenario for this path
            # Filter  --> [Whitelist Rules-> [include "NON matching"]]

            [whitelist_non_matcher_clause] # abstract
          end
        elsif list_type == :whitelist
          # no white list rules were available for this repo
          # so we need to return an all matcher class
          # something like  => {"unit_id" => {"$exists" => true}}
          # meaning "copy any unit that has an id"
          # We need this to not make the "copy" copy everything.
          # example scenario for this path
          # Filter  -->  [Whitelist Rules-> [<none provided>], Blacklist Rule -> [remove foo]]
          #
          [whitelist_all_matcher_clause] # abstract
        end
      end
    end
  end
end
