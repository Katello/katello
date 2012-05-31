# -*- coding: utf-8 -*-

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

import os
import sys
from gettext import gettext as _
from katello.client.i18n_optparse import OptionParser, OptionParserExitError
from M2Crypto import SSL
from socket import error as SocketError
from urlparse import urlparse

from katello.client.config import Config
from katello.client.api.utils import ApiDataError
from katello.client.core.utils import parse_tokens, SystemExitRequest
from katello.client.utils.printer import Printer, GrepStrategy, VerboseStrategy
from katello.client.utils.option_validator import OptionValidator
from katello.client.utils.encoding import u_str, u_obj
from katello.client.logutil import getLogger
from katello.client.server import ServerRequestError

from copy import copy
from optparse import Option, OptionValueError

Config()
_log = getLogger(__name__)

# base command class ----------------------------------------------------------
#
# NOTE: If you are adding or removing Commands and Actions you
# need to edit:
#
# katello/bin/kp-cmd
#
# They contain the mapping and lists of Commands and Actions for
# everything the CLI can do.


class Command(object):

    def __init__(self):
        self.__subcommands = {}
        self.opts = None
        self.args = None

    def usage(self, command_path):
        """
        Usage string.
        @rtype: str
        @return: command's usage string
        """
        if command_path:
            usage_line = " <options> ".join(command_path)
        else:
            usage_line = ""
        usage_line += " <command>"
        lines = [usage_line, 'Supported Commands:']
        for name in sorted(self.get_subcommand_names()):
            lines += self.__build_command_usage_lines(name, self.get_subcommand(name))
        return '\n'.join(lines)

    def __build_command_usage_lines(self, name, command):
        lines = []
        desc_lines = command.description.split("\n")

        lines.append('\t%-14s %s' % (name, desc_lines.pop(0)) )
        for l in desc_lines:
            lines.append('\t%-14s %s' % (" ", l) )

        return lines


    def add_subcommand(self, name, command):
        self.__subcommands[name] = command

    def get_subcommand_names(self):
        return self.__subcommands.keys()

    def get_subcommand(self, name):
        if name in self.__subcommands:
            return self.__subcommands[name]
        raise Exception("Command not found")

    def create_parser(self, command_path=None):
        parser = OptionParser(option_class=KatelloOption)
        parser.disable_interspersed_args()
        parser.set_usage(self.usage(command_path))
        self.setup_parser(parser)
        return parser


    def setup_parser(self, parser):
        """
        Add custom options to the parser
        @note: this method should be overridden to add per-action options
        """
        pass

    def process_options(self, parser, args):
        self.opts, self.args = parser.parse_args(args)


    def _extract_command(self, parser, args):
        #import pdb
        #pdb.set_trace()
        if not args:
            parser.error(_('no action given: please see --help'))

        try:
            command = self.get_subcommand(args[0])
            return command
        except:
            parser.error(_('invalid action: please see --help'))
            return None

    def run(self):
        pass

    def main(self, args, command_path=None):
        if type(args) == str:
            args = parse_tokens(args)

        parser = self.create_parser(command_path)
        self.process_options(parser, args)
        if command_path is not None:
            command_path.append(self.args[0])
        self.run()
        return self._extract_command(parser, self.args).main(self.args[1:], command_path)



# base action class -----------------------------------------------------------

class Action(object):
    """
    Action class representing a single action for a cli command
    @ivar name: action's name
    @ivar parser: optparse.OptionParser instance
    @ivar opts: options returned from parsing command line
    @ivar args: arguments returned from parsing command line
    """

    def __init__(self):
        self.cmd = None
        self.name = None
        self.opts = None
        self.args = None
        self.printer = None

    def usage(self, command_path = None):
        """
        Usage string.
        @rtype: str
        @return: command's usage string
        """
        if command_path:
            usage_line = " <options> ".join(command_path)
        else:
            usage_line = ""
        usage_line += " <options>"
        return usage_line

    @property
    def description(self):
        """
        Return a string for this action's description
        """
        return _('no description available')

    def create_parser(self, command_path=None):
        parser = OptionParser(option_class=KatelloOption)
        parser.add_option('-g', dest='grep',
                        action="store_true",
                        help=_("grep friendly output"))
        parser.add_option('-v', dest='verbose',
                        action="store_true",
                        help=_("verbose, more structured output"))
        parser.add_option('-d', dest='delimiter',
                        default="",
                        help=_("column delimiter in grep friendly output, works only with option -g"))
        parser.set_usage(self.usage(command_path))
        self.setup_parser(parser)
        return parser

    def create_validator(self, parser, opts, args):
        return OptionValidator(parser, opts, args)

    def create_printer(self, strategy):
        return Printer(strategy)

    def get_option(self, opt_dest):
        """
        Get an option from opts or from the config file
        Options from opts take precedence.
        @type opt: str
        @param opt: name of option to get
        @return: value of the option or None if the option is no present
        """
        attr = getattr(self.opts, opt_dest, None)
        return u_obj(attr)

    def has_option(self, opt):
        """
        Check if option is present
        @type opt: str
        @param opt: name of option to check
        @return True if the option was set, otherwise False
        """
        return (not self.get_option(opt) is None)

    def setup_parser(self, parser):
        """
        Add custom options to the parser
        @note: this method should be overridden to add per-action options
        """
        pass

    def run(self):
        """
        Action's functionality
        @note: override this method to implement the actoin's functionality
        @raise NotImplementedError: if this method is not overridden
        """
        raise NotImplementedError('Base class method called')

    def check_options(self, validator):
        """
        Add custom option requirements
        @note: this method should be overridden to check for required options
        """
        return

    def __print_strategy(self):
        if (self.has_option('grep') or (Config.parser.has_option('interface', 'force_grep_friendly') and Config.parser.get('interface', 'force_grep_friendly').lower() == 'true')):
            return GrepStrategy(delimiter=self.get_option('delimiter'))
        elif (self.has_option('verbose') or (Config.parser.has_option('interface', 'force_verbose') and Config.parser.get('interface', 'force_verbose').lower() == 'true')):
            return VerboseStrategy()
        else:
            return None

    def load_saved_options(self, parser):
        if not Config.parser.has_section('options'):
            return
        for opt_name, opt_value in Config.parser.items('options'):
            opt = parser.get_option_by_name(opt_name)
            if not opt is None:
                parser.set_default(opt.get_dest(), opt_value)

    def extract_action(self, args):
        """
        this method exists so that an action can run like a command
        it supports having single name actions (e.g. katello shell)
        """
        pass

    def require_credentials(self):
        """
        if True, credentials are required when calling the command.
        @note: this method should be overriden, if credentials should not be checked for action
        """
        return True

    def error(self, error_msg):
        error_msg = u_str(error_msg)
        _log.error("error: %s" % error_msg)
        if error_msg == '':
            msg = _('error: operation failed')
        else:
            msg = error_msg
        print >> sys.stderr, msg


    def setup_action(self, args, command_path=None):
        parser = self.create_parser(command_path)
        self.load_saved_options(parser)
        self.process_options(parser, args)

        self.printer = self.create_printer(self.__print_strategy())

    def process_options(self, parser, args):
        self.opts, self.args = parser.parse_args(args)

        validator = self.create_validator(parser, self.opts, self.args)
        self.check_options(validator)
        self.__process_option_errors(parser, validator.opt_errors)

    def __process_option_errors(self, parser, errors):
        if len(errors) == 1:
            parser.error(errors[0])
        elif len(errors) > 0:
            parser.error(errors)


    def main(self, args, command_path=None):
        """
        Main execution of the action
        This method setups up the parser, parses the arguments, and calls run()
        in a try/except block, handling RestlibExceptions and general errors
        @warning: this method should only be overridden with care
        """
        try:
            self.setup_action(args, command_path)
            return self.run()

        except SSL.Checker.WrongHost, wh:
            print _("ERROR: The server hostname you have configured in /etc/katello/client.conf does not match the")
            print _("hostname returned from the katello server you are connecting to.  ")
            print ""
            print _("You have: [%s] configured but got: [%s] from the server.") % (wh.expectedHost, wh.actualHost)
            print ""
            print _("Please correct the host in the /etc/katello/client.conf file")
            sys.exit(1)

        except ServerRequestError, re:
            try:
                if "displayMessage" in re.args[1]:
                    msg = re.args[1]["displayMessage"]
                else:
                    msg = ", ".join(re.args[1]["errors"])
            except:
                msg = re.args[1]
            if re.args[0] == 401:
                msg = _("Invalid credentials or unable to authenticate")

            self.error(msg)
            return re.args[0]

        except SocketError, se:
            self.error(se.args[1])
            return se.args[0]

        except OptionParserExitError, opee:
            return opee.args[0]

        except ApiDataError, ade:
            print >> sys.stderr, ade.args[0]
            return os.EX_DATAERR

        except SystemExitRequest, ser:
            msg = "\n".join(ser.args[1]).strip()
            if ser.args[0] == os.EX_OK:
                out = sys.stdout
                _log.error("error: %s" % u_str(msg))
            else:
                out = sys.stderr

            if msg != "":
                print >> out, msg
            return ser.args[0]

        except KeyboardInterrupt:
            return os.EX_NOUSER

        print ''

# optparse type extenstions --------------------------------------------------



def check_bool(option, opt, value):
    if value.lower() in ["true","false"]:
        return (value.lower() == "true")
    else:
        raise OptionValueError(_("option %s: invalid boolean value: %r") % (opt, value))

def check_list(option, opt, value):
    if not option.delimiter:
        delimiter = ","
    else:
        delimiter = option.delimiter

    if not value.strip():
        return []
    return [item.strip() for item in value.split(delimiter)]

def check_url(option, opt, value):
    if not option.schemes:
        schemes = ["http","https"]
    else:
        schemes = option.schemes

    url_parsed = urlparse(value)
    if not url_parsed.scheme in schemes:                                 # pylint: disable=E1101
        formatted_schemes = " or ".join([s+"://" for s in schemes])
        raise OptionValueError(_('option %s: has to start with %s') % (opt, formatted_schemes))
    elif not url_parsed.netloc:                                          # pylint: disable=E1101
        raise OptionValueError(_('option %s: invalid format') % (opt))
    return value

class KatelloOption(Option):
    TYPE_CHECKER = copy(Option.TYPE_CHECKER)
    TYPES = copy(Option.TYPES)
    ATTRS = copy(Option.ATTRS)

    TYPE_CHECKER["bool"] = check_bool
    TYPES = TYPES + ("bool", )

    TYPE_CHECKER["list"] = check_list
    TYPES += ("list", )
    ATTRS += ["delimiter", ]

    TYPE_CHECKER["url"] = check_url
    TYPES += ("url", )
    ATTRS += ["schemes", ]

    def get_name(self):
        return self.get_opt_string().lstrip('-')

    def get_dest(self):
        return self.dest
