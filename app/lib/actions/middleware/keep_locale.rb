module Actions
  module Middleware
    # Keeps the locale value from plan and keeps that in run/finalize
    # so that the error from there are localized correctly
    class KeepLocale < Dynflow::Middleware
      def plan(*args)
        pass(*args).tap { action.input[:locale] = I18n.locale }
      end

      def run(*args)
        with_locale { pass(*args) }
      end

      def finalize
        with_locale { pass }
      end

      private

      def with_locale(&_block)
        I18n.locale = action.input[:locale]
        yield
      ensure
        I18n.locale = nil
      end
    end
  end
end
