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

    def self.active_record_search_classes
      ignore_list =  ["CpConsumerUser", "Pool"]
      classes = get_subclasses(ActiveRecord::Base)
      classes = classes.select{ |c| !ignore_list.include?(c.name) && c.respond_to?(:index) }

      #we need index base classes first (TaskStatus) before child classes (PulpTaskStatus)
      initial_list = classes.select{|c| c.superclass == ActiveRecord::Base}
      subclass_list = classes - initial_list
      initial_list + subclass_list
    end

    def self.get_subclasses(obj_class)
      classes = obj_class.subclasses
      subs = classes.collect {|c| get_subclasses(c) }.flatten
      classes + subs
    end

  end
end
