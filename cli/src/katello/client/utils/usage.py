# -*- coding: utf-8 -*-
#
# Copyright © 2010 Red Hat, Inc.
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

# This man page / usage generator is used in the katello-cli.spec file.

# configure config to load it from working directory rather than from /etc
import os
from katello.client.config import Config
Config.PATH = os.path.join(os.path.dirname(__file__), "../../../../etc/client.conf")

from katello.client.main import setup_admin


# helper class to collect commands and actions
class ParamsCollector():
    commands = {}
    def add_command(self, command_name, command):
        self.commands[command_name] = command

class UsageGenerator:
    def __init__(self):
        self.__collector = ParamsCollector()

    def collector(self):
        return self.__collector

    def print_usage(self):
        print "  Possible commands:"
        for command in iter(sorted(self.__collector.commands.iteritems())):
            print "    " + command[0] + " - " + command[1].description
        for command in iter(sorted(self.__collector.commands.iteritems())):
            print "\n  Command 'katello %s':" % command[0]
            try:
                for name in command[1]._action_order:
                    action = command[1]._actions[name]
                    print "    %s - %s" % (action.name, action.description)
            except AttributeError:
                print "    no actions available"

if __name__ == "__main__":
    usage_gen = UsageGenerator()
    setup_admin(usage_gen.collector())
    usage_gen.print_usage()
