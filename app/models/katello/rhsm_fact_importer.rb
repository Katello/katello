module Katello
  class RhsmFactImporter < ::FactImporter
    def fact_name_class
      Katello::RhsmFactName
    end

    def initialize(host, facts = {})
      super
      @facts = change_separator(@facts)
    end

    def change_separator(facts)
      to_ret = {}
      facts.each do |key, value|
        to_ret[key.split('.').join(RhsmFactName::SEPARATOR)] = value
      end
      to_ret
    end

    def add_new_facts
      @facts.keys.each { |key| add_fact_name(key) }
      super
    end

    def add_fact_name(name, is_parent = false)
      begin
        parent_name = find_parent(name)
        parent_fact_name = add_fact_name(parent_name, true) if parent_name
        fact_name = RhsmFactName.where(:name => name).first_or_create! do |new_fact|
          new_fact.parent = parent_fact_name
          new_fact.compose = is_parent
        end
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        retry
      end
      FactValue.create(:fact_name => fact_name, :value => nil, :host => @host) if is_parent
      fact_name
    end

    def find_parent(name)
      split = name.split(Katello::RhsmFactName::SEPARATOR)
      split[0..split.length - 2].join(Katello::RhsmFactName::SEPARATOR) if split.length > 1
    end
  end
end
