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

module SearchHelperMethods
  def setup_search options = {}, &block
    Tire::Index.instance_eval do
      define_method(:exists?) do
        true
      end

    end

    results = Util::Support.array_with_total.concat(options[:results] || [])

    Tire::Search::Search.instance_eval do
      define_method(:perform) do
        unless block_given?
          data = to_hash
          (data[:fields].should == options[:fields]) if options.has_key?(:fields)
          (data[:query].should == options[:query]) if options.has_key?(:query)
          (SearchHelperMethods.compare_filter_params(options[:filter], data[:filter]).should == true) if options.has_key?:filter
          (data[:size].should == options[:size]) if options.has_key?(:size)
          (data[:sort].should == options[:sort])if options.has_key?(:sort)
          (data[:from].should == options[:from])if options.has_key?(:from)

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

  def SearchHelperMethods.compare_filter_params(expected, actual)
    return false if expected.class != actual.class
    return expected == actual unless Hash === expected || Array === expected

    if Array === expected
      return false if expected.size != actual.size
      expected.all? do |item|
        unless actual.include? item
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
