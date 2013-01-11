#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class UserMailer < ActionMailer::Base
  include AsyncOrchestration

  default :from => Katello.config.email_reply_address

  def send_password_reset(user)
    # TODO: temporarily hardcoding org to the first org... this will be changed to use the user's default org, once
    # that logic is merged in
    org = Organization.find(1)
    User.current = user
    UserMailer.async(:organization => org).password_reset(user, I18n.locale)
  end

  def send_logins(users)
    # TODO: temporarily hardcoding org to the first org... this will be changed to use the user's default org, once
    # that logic is merged in
    org = Organization.find(1)
    UserMailer.async(:organization => org).logins(users, I18n.locale)
  end

  def password_reset(user, locale)
    I18n.locale = locale
    @user = user
    mail :to => user.email, :subject => _("Katello User '%s' Password Reset") % user.username
  end

  def logins(users, locale)
    I18n.locale = locale
    @email = users.first.email
    @users = users
    mail :to => @email, :subject => _("Katello Logins")
  end
end
