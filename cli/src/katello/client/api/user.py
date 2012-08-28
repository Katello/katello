# -*- coding: utf-8 -*-
#
# Copyright © 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

from katello.client.api.base import KatelloAPI
from katello.client.utils.encoding import u_str

class UserAPI(KatelloAPI):
    """
    Connection class to access User Data
    """
    def create(self, name, pw, email, disabled, default_environment, default_locale=None):
        userdata = {"username": name,
                    "password": pw,
                    "email": email,
                    "disabled": disabled}

        if default_locale is not None:
            userdata["default_locale"] = default_locale

        if default_environment is not None:
            userdata.update(default_environment_id=default_environment['id'])

        path = "/api/users/"
        return self.server.POST(path, userdata)[1]

    def delete(self, user_id):
        path = "/api/users/%s" % u_str(user_id)
        return self.server.DELETE(path)[1]

    def update(self, user_id, pw, email, disabled, default_environment, default_locale=None):
        userdata = {}
        userdata = self.update_dict(userdata, "password", pw)
        userdata = self.update_dict(userdata, "email", email)
        userdata = self.update_dict(userdata, "disabled", disabled)

        if default_environment is None:
            userdata.update(default_environment_id=None)                        # pylint: disable=E1101
        elif default_environment is not False:
            userdata.update(default_environment_id=default_environment['id'])   # pylint: disable=E1101

        if default_locale is not None:
            userdata = self.update_dict(userdata, "default_locale", default_locale)

        path = "/api/users/%s" % u_str(user_id)
        return self.server.PUT(path, {"user": userdata})[1]

    def users(self, query=None):
        path = "/api/users/"
        users = self.server.GET(path, query)[1]
        return users

    def user(self, user_id):
        path = "/api/users/%s" % u_str(user_id)
        user = self.server.GET(path)[1]
        return user

    def user_by_name(self, user_name):
        users = self.users({"username": user_name})
        if len(users) >= 1:
            return users[0]
        else:
            return None

    def sync_ldap_roles(self):
        path = "/api/users/sync_ldap_roles/"
        return self.server.GET(path)[1]


    def assign_role(self, user_id, role_id):
        path = "/api/users/%s/roles" % u_str(user_id)
        data = {"role_id": role_id}
        return self.server.POST(path, data)[1]

    def unassign_role(self, user_id, role_id):
        path = "/api/users/%s/roles/%s" % (u_str(user_id), u_str(role_id))
        return self.server.DELETE(path)[1]

    def roles(self, user_id):
        path = "/api/users/%s/roles/" % u_str(user_id)
        return self.server.GET(path)[1]

    def report(self, format_in):
        to_return = self.server.GET("/api/users/report", custom_headers={"Accept": format_in})
        return (to_return[1], to_return[2])
