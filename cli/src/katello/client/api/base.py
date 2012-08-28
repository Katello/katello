# -*- coding: utf-8 -*-
#
# Copyright © 2011 Red Hat, Inc.
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

from katello.client import server


class KatelloAPI(object):
    """
    Base api class that allows an internal server object to be set after
    instantiation.
    @ivar server: L{Server} instance
    """

    def __init__(self):
        pass

    @property
    @classmethod
    def server(cls):
        return server.active_server

    @classmethod
    def update_dict(cls, d, key, value):
        """
        Update value for key in fictionary only if the value is not None.
        """
        if value != None:
            d[key] = value
        return d
