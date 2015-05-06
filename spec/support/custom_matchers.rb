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
    fail ArgumentError, 'type cannot be nil' if @types.blank?

    @controller   = controller
    notifier_mock = RSpec::Mocks::Mock.new('NotifierImpl', :__declared_as => 'Mock')
    @types.each do |type|
      notifier_mock.should_receive(type).and_return do |*args|
        args = args.map do |arg|
          case arg
          when Exception
            "#{arg.message} (#{arg.class})\n#{arg.backtrace.join("\n")}"
          else
            arg.inspect
          end
        end
        args = args.join("\n")
        Rails.logger.debug("notify.#{type} received with:\n" + args)
        true
      end
    end
    @controller.should_receive(:notify).any_number_of_times.and_return(notifier_mock)

    # always return true, should_receive will handle the errors
    return true
  end
end

def must_notify_with(type)
  notify = Katello::Notifications::Notifier.new
  notify.expects(type).at_least_once
  @controller.expects(:notify).at_least_once.returns(notify)
end

=begin
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
=end
