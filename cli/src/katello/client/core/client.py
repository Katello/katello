#
# Katello Repos actions
# Copyright 2013 Red Hat, Inc.
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

from katello.client.config import Config
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.encoding import u_str


# base system action --------------------------------------------------------

class ClientAction(BaseAction):

    def __init__(self):
        super(ClientAction, self).__init__()


# system actions ------------------------------------------------------------

class Remember(ClientAction):

    description = _('save an option to the client config')

    def setup_parser(self, parser):
        parser.add_option('--option', dest='option',
                       help=_("name of the option to be saved (e.g. org, environment, provider, etc) (required)"))
        parser.add_option('--value', dest='value',
                       help=_("value to be store under specified option (required)"))

    def check_options(self, validator):
        validator.require(('option', 'value'))

    def run(self):
        option = self.opts.option
        value = self.opts.value

        Config()
        if not Config.parser.has_section('options'):
            Config.parser.add_section('options')

        has_option = Config.parser.has_option('options', option)
        Config.parser.set('options', option, value)

        try:
            Config.save()
            if has_option:
                print _("Successfully overwrote option [ %s ] ") % u_str(option)
            else:
                print _("Successfully remembered option [ %s ] ") % u_str(option)
        except (Exception):
            print _("Unsuccessfully remembered option [ %s ]") % u_str(option)
            raise # re-raise to get into main method -> log

        return os.EX_OK

class Forget(ClientAction):

    description = _('remove an option from the client config')

    def setup_parser(self, parser):
        parser.add_option('--option', dest='option',
                       help=_("name of the option to be deleted (required)"))

    def check_options(self, validator):
        validator.require('option')

    def run(self):
        option = self.opts.option

        Config()
        Config.parser.remove_option('options', option)
        try:
            Config.save()
            print _("Successfully forgot option [ %s ]") % u_str(option)
        except (Exception):
            print _("Unsuccessfully forgot option [ %s ]") % u_str(option)
            raise # re-raise to get into main method -> log

        return os.EX_OK

class SavedOptions(ClientAction):

    description = _('list options saved in the client config')

    def setup_parser(self, parser):
        pass

    def check_options(self, validator):
        pass

    def run(self):
        self.printer.set_header(_("Saved Options"))

        Config()
        if Config.parser.has_section('options'):
            options = Config.parser.options('options')

            options_list = [{'option': o, 'value': Config.parser.get('options', o)} for o in options]

            self.printer.add_column('option', _("Option"))
            self.printer.add_column('value', _("Value"))
            self.printer.print_items(options_list)

        return os.EX_OK

class Client(Command):

    description = _('client specific actions in the katello server')
