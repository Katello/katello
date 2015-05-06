module Katello
  module SearchHelperMethods
    def setup_search(options = {}, &block)
      Tire::Index.instance_eval do
        define_method(:exists?) do
          true
        end
      end

      results = Util::Support.array_with_total.concat(options[:results] || [])

      Tire::Search::Search.instance_eval do
        define_method(:perform) do
          if !block_given?
            data = to_hash
            (data[:fields].must_equal options[:fields]) if options.key?(:fields)
            (data[:query].must_equal options[:query]) if options.key?(:query)
            (SearchHelperMethods.compare_filter_params(options[:filter], data[:filter]).must_equal true) if options.key?(:filter)
            (data[:size].must_equal options[:size]) if options.key?(:size)

            #http://www.fngtps.com/2007/using-openstruct-as-mock-for-activerecord/
            OpenStruct.instance_eval do
              define_method(:id) do
                @table[:id]
              end
            end

            OpenStruct.new(:results => results)
          else
            Tire::Search::Search.instance_eval(&block)
          end
        end
      end
    end

    def reset_search
      Tire::Search::Search.instance_eval do
        define_method(:perform) do
          OpenStruct.new(:results => OpenStruct.new(:total => 0, :results => []))
        end
      end
    end

    def self.compare_filter_params(expected, actual)
      return false if expected.class != actual.class
      return expected == actual unless expected.is_a?(Hash) || expected.is_a?(Array)

      if expected.is_a?(Array)
        return false if expected.size != actual.size
        expected.all? do |item|
          if !actual.include? item
            actual.any? do |act|
              compare_filter_params(item, act)
            end
          else
            true
          end
        end
      else
        expected.each do |key, value|
          actual_value = actual[key]
          return false unless compare_filter_params(value, actual_value)
        end
        true
      end
    end
  end
end
