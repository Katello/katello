# -*- coding: utf-8 -*-
#
# Katello Organization actions
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

from katello.client.api.${resource.name(True, False)} import ${resource.name(True, True)}API
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import test_record


# base ${resource.name()} action --------------------------------------------------------

class ${resource.name(True, True)}Action(BaseAction):

    def __init__(self):
        super(${resource.name(True, True)}Action, self).__init__()
        self.api = ${resource.name(True, True)}API()

# ${resource.name()} actions ------------------------------------------------------------

#TODO: fill the actions

# ${resource.name()} command ------------------------------------------------------------

class ${resource.name(True, True)}(Command):

    description = _('${resource.name()} specific actions in the katello server')
