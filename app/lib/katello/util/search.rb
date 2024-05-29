module Katello
  module Util
    module Search
      DISABLED_LUCENE_SPECIAL_CHARS = ['-', ':'].freeze

      def self.custom_analyzers
        {
          "kt_name_analyzer" => {
            "type" => "custom",
            "tokenizer" => "keyword",
          },
          "autcomplete_name_analyzer" => {
            "type" => "custom",
            "tokenizer" => "keyword",
            "filter" => %w(standard lowercase ngram_filter),
          },
        }
      end

      def self.custom_filters
        {
          "ngram_filter" => {
            "type" => "edgeNGram",
            "side" => "front",
            "min_gram" => 1,
            "max_gram" => 30,
          },
        }
      end

      # Filter the search input, escaping unsupported lucene syntax (e.g. usage of - operator)
      def self.filter_input(search)
        return nil if search.nil?
        DISABLED_LUCENE_SPECIAL_CHARS.each do |chr|
          search = search.gsub(chr, '\\' + chr)
        end
        return search
      end

      def self.active_record_search_classes
        ignore_list = %w(Katello::CpConsumerUser Katello::Pool)
        classes = get_subclasses(ActiveRecord::Base)
        classes = classes.select { |c| !ignore_list.include?(c.name) && c.respond_to?(:index) }

        initial_list = classes.select { |c| c.superclass == ActiveRecord::Base }
        subclass_list = classes - initial_list
        initial_list + subclass_list
      end

      def self.get_subclasses(obj_class)
        classes = obj_class.subclasses
        subs = classes.collect { |c| get_subclasses(c) }.flatten
        classes + subs
      end
    end
  end
end
