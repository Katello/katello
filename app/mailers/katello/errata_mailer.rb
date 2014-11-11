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

module Katello
  class ErrataMailer < ApplicationMailer
    helper :'katello/errata_mailer'

    def host_errata(options)
      return unless (user = User.find(options[:user]))

      @content_hosts = Katello::System.authorized_as(user, :view_content_hosts).reject { |host| host.applicable_errata.empty? }

      set_locale_for user

      mail(:to        => user.mail,
           :subject   => _("Katello Host Advisory"),
           :date      => Time.zone.now)
    end

    private

    def errata_counts(errata)
      counts = {:total => errata.count}
      counts.merge(Hash[[:security, :bugfix, :enhancement].collect do |errata_type|
        [errata_type, errata.send(errata_type).count]
      end])
    end
  end
end
