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

# This man page / usage generator is used in the katello-cli.spec file.

# configure config to load it from working directory rather than from /etc
import os
from katello.client.config import Config
Config.PATH = os.path.join(os.path.dirname(__file__), "../../../../etc/client.conf")

from katello.client.main import setup_admin
from katello.client.core.base import CommandContainer


class UsageGenerator:
    def __init__(self):
        self.__collector = CommandContainer()

    def collector(self):
        return self.__collector

    @classmethod
    def _print_subcommands_for(cls, cmd):
        if not isinstance(cmd, CommandContainer):
            return
        for subcommand_name in iter(sorted(cmd.get_command_names())):
            print "    %s - %s" % (subcommand_name, cmd.get_command(subcommand_name).description)


    def _process_subcommands_for(self, cmd, parent_name):

        for subcommand_name in iter(sorted(cmd.get_command_names())):
            subcmd = cmd.get_command(subcommand_name)

            if not isinstance(subcmd, CommandContainer):
                continue
            print "\n  Command '%s %s':" % (parent_name, subcommand_name)
            self._print_subcommands_for(subcmd)
            self._process_subcommands_for(subcmd, parent_name+" "+subcommand_name)

    def print_usage(self):
        print "  Possible commands:"
        self._print_subcommands_for(self.__collector)
        self._process_subcommands_for(self.__collector, "katello")


if __name__ == "__main__":
    usage_gen = UsageGenerator()
    setup_admin(usage_gen.collector())
    usage_gen.print_usage()
