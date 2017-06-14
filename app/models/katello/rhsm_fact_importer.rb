module Katello
  class RhsmFactImporter < ::StructuredFactImporter
    def fact_name_class
      Katello::RhsmFactName
    end

    def normalize(facts)
      facts = super
      facts = change_separator(facts)
      add_compose_facts(facts)
    end

    def add_compose_facts(facts)
      additional_keys = []
      facts.keys.each do |fact_name|
        parts = fact_name.split(RhsmFactName::SEPARATOR)
        additional_keys += parts[0..-2].reduce([]) { |memo, part| memo << [memo.last, part].compact.join(RhsmFactName::SEPARATOR) }
      end

      # add the facts hierarchy to facts hash
      additional_keys.uniq.each do |key|
        facts[key] = nil
      end
      facts
    end

    def change_separator(facts)
      to_ret = {}
      facts.each do |key, value|
        to_ret[key.split('.').join(RhsmFactName::SEPARATOR)] = value
      end
      to_ret
    end
  end
end
