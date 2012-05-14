#
# Katello Organization actions
# Copyright (c) 2010 Red Hat, Inc.
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

from gettext import gettext as _

from katello.client.api.version import VersionAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command

Config()

# base ping action --------------------------------------------------------

class VersionAction(Action):

    def __init__(self):
        super(VersionAction, self).__init__()
        self.api = VersionAPI()



# version actions ------------------------------------------------------------

class Info(VersionAction):

    description = _('get the version of the katello server')

    def setup_parser(self):
        return 0

    def check_options(self):
        return 0

    def run(self):
        return self.api.version_formatted()


# ping command ------------------------------------------------------------

class Version(Command):
    description = _('Check the version of the server')
