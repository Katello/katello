#
# Make optparse friendlier to i18n/l10n
#
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

"""
Make optparse friendlier to i18n/l10n

Just use this instead of optparse, the interface should be the same.

For some backgorund, see:
http://bugs.python.org/issue4319
"""

import sys

from optparse import OptionParser as _OptionParser

class OptionParserExitError(Exception):
    """
    Exception to indicate exit call from OptionParser.
    Takes error code as it's only argument.
    """
    pass


class OptionParser(_OptionParser):

    # These are a bunch of strings that are marked for translation in optparse,
    # but not actually translated anywhere. Mark them for translation here,
    # so we get it picked up. for local translation, and then optparse will
    # use them.
    @classmethod
    def no_op(cls):
        _("Usage: %s\n")
        _("Usage")
        _("%prog [options]")
        _("Options")

        # stuff for option value sanity checking
        _("no such option: %s")
        _("ambiguous option: %s (%s?)")
        _("%s option requires an argument")
        _("%s option requires %d arguments")
        _("%s option does not take a value")
        _("integer")
        _("long integer")
        _("floating-point")
        _("complex")
        _("option %s: invalid %s value: %r")
        _("option %s: invalid choice: %r (choose from %s)")

        # default options
        _("show this help message and exit")
        _("show program's version number and exit")

    displayed_help = False

    def print_help(self, out_file=None):
        if out_file is None:
            out_file = sys.stdout
        self.displayed_help = True
        out_file.write(self.format_help())


    def exit(self, status=0, msg=None):
        """
        Overridden method for means of CLI. Doesn't exit the whole script but
        raises OptionParserExitError
        """
        if msg:
            sys.stderr.write(msg)
        raise OptionParserExitError(status)


    def error(self, errorMsg):
        """
        Print usage, one or more error messages and call exit.
        """
        if isinstance(errorMsg, list):
            self.print_usage(sys.stderr)

            i = 0
            while (i<len(errorMsg)):
                errorMsg[i] = str(i+1) +") "+ errorMsg[i] +"\n"
                i += 1
            msgs = ''.join(errorMsg)

            self.exit(2, "%s: errors:\n%s" % (self.get_prog_name(), msgs))
        else:
            _OptionParser.error(self, errorMsg)


    def get_option_by_dest(self, dest):
        for opt in self.option_list:
            if opt.dest == dest:
                return opt
        return None


    def get_option_by_name(self, name):
        for opt in ['--'+name, '-'+name]:
            if self.has_option(opt):
                return self.get_option(opt)
        return None


    def get_options(self):
        return self._long_opt.keys() + self._short_opt.keys()

    def get_long_options(self):
        return self._long_opt.keys()

    def get_short_options(self):
        return self._long_opt.keys()
