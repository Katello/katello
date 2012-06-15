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

module Katello
  module Search

    DISABLED_LUCENE_SPECIAL_CHARS = ['-', ':']

    def self.custom_analyzers
      {
        "kt_name_analyzer" => {
          "type"      => "custom",
          "tokenizer" => "keyword",
          "filter"    => ["lowercase", "asciifolding"]
        },
        "autcomplete_name_analyzer" => {
            "type"      => "custom",
            "tokenizer" => "keyword",
            "filter"    => ["standard", "lowercase", "asciifolding", "ngram_filter"]
        }
      }
    end

    def self.custom_filters
      {
          "ngram_filter"  => {
              "type"      => "edgeNGram",
              "side"      => "front",
              "min_gram"  => 1,
              "max_gram"  => 30
          }
      }
    end

    # Filter the search input, escaping unsupported lucene syntax (e.g. usage of - operator)
    def self.filter_input search
      return nil if search.nil?
      DISABLED_LUCENE_SPECIAL_CHARS.each do |chr|
        search = search.gsub(chr, '\\'+chr)
      end
      return search
    end

  end
end