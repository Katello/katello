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