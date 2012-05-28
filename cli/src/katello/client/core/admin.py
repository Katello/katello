# -*- coding: utf-8 -*-
#
# Katello User actions
# Copyright (c) 2012 Red Hat, Inc.
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
#

import os
from gettext import gettext as _

from katello.client.api.admin import AdminAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command

Config()

# base user action -----------------------------------------------------

class AdminAction(Action):

    def __init__(self):
        super(AdminAction, self).__init__()
        self.api = AdminAPI()


# user actions ---------------------------------------------------------

class CrlRegen(AdminAction):

    description = _('re-generate certificate revocation lists')

    def run(self):
        self.api.crl_regen()
        return os.EX_OK


# user command ------------------------------------------------------------

class Admin(Command):

    description = _('various administrative actions')
