#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
