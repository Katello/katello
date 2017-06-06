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

module CustomMatchers
  class Notify
    def initialize(*types)
      @types = types
    end

    def method_missing(method, *args, &block)
      if args.blank? && block.nil?
        @types << method.to_sym
        return self
      else
        super
      end
    end

    def matches?(controller)
      raise ArgumentError, 'type cannot be nil' if @types.blank?

      @controller   = controller
      notifier_mock = RSpec::Mocks::Mock.new('NotifierImpl', :__declared_as => 'Mock')
      @types.each do |type|
        notifier_mock.should_receive(type).and_return do |*args|
          Rails.logger.debug("notify.#{type} received with:\n" + args.map do |arg|
            case arg
              when Exception
                "#{arg.message} (#{arg.class})\n#{arg.backtrace.join("\n")}"
              else
                arg.inspect
            end
          end.join("\n"))
          true
        end
      end
      @controller.should_receive(:notify).any_number_of_times.and_return(notifier_mock)

      # always return true, should_receive will handle the errors
      return true
    end
  end

  def notify(*types)
    Notify.new(*types)
  end

end

# @response.body.should be_json({:my => {:expected => ["json","hash"]}})
# @response.body.should be_json('{"my":{"expected":["json","hash"]}}')
RSpec::Matchers.define :be_json do |expected|
  match do |actual|
    actual = ActiveSupport::JSON.decode(actual)
    if actual.is_a? Array
      actual.map { |item| item.with_indifferent_access }
    else
      actual = actual.with_indifferent_access
    end

    expected = ActiveSupport::JSON.decode(expected) unless expected.is_a?(Hash) || expected.is_a?(Array)
    if expected.is_a? Array
      expected.map { |item| item.with_indifferent_access if item.is_a?(Hash) }
    else
      expected = expected.with_indifferent_access
    end

    if actual.is_a?(Array) && expected.is_a?(Array)
      actual.should match_array(expected)
    else
      actual.diff(expected) == {}
    end
  end
end
