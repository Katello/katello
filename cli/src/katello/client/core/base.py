# -*- coding: utf-8 -*-

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


class CommandContainer(object):
    """
    Container that can hold commands and actions.
    """

    def __init__(self):
        self.__subcommands = {}

    def add_command(self, name, command):
        """
        Add command or action

        :param name: a name undher which the command/action will be registered
        :type name: string
        :param command: 
        :type command: Action|Command
        """
        self.__subcommands[name] = command

    def remove_command(self, name):
        """
        :param name: a name undher which the command/action is registered
        :type name: string
        """
        del self.__subcommands[name]

    def get_command_names(self):
        """
        :rtype: list of strings
        """
        return self.__subcommands.keys()

    def get_command(self, name):
        """
        :raises Exception: if the command was not found
        :return: command or action registered under the given name
        """
        if name in self.__subcommands:
            return self.__subcommands[name]
        raise Exception("Command not found")



class Action(object):
    """
    Class implementing common functionality for CLI commands and actions
    
    :ivar parser: optparse.OptionParser instance
    :ivar takes_options: bool flag that says whether the action has any options
    :ivar opts: options returned from parsing command line
    :ivar args: arguments returned from parsing command line
    """

    opts = None
    args = None
    takes_options = True

    def _get_usage_line(self, command_name, parent_usage):
        first_line = parent_usage or ""
        first_line += " "
        first_line += command_name or ""
        if self.takes_options:
            first_line += " <options>"
        return first_line

    def usage(self, command_name=None, parent_usage=None):
        """
        Usage string.

        :rtype: str
        :return: command's usage string
        """
        return "Usage: "+self._get_usage_line(command_name, parent_usage)


    @property
    def description(self):
        """
        Return a string with this action's description
        """
        return _('no description available')

    def create_parser(self, command_name=None, parent_usage=None):
        """
        Create an instance of option parser
        
        :rtype: OptionParser
        """
        parser = OptionParser(option_class=KatelloOption)
        self.setup_parser(parser)
        parser.set_usage(self.usage(command_name, parent_usage))
        return parser

    def create_validator(self, parser, opts, args):
        """
        :rtype: OptionValidator
        """
        return OptionValidator(parser, opts, args)

    def get_option(self, opt_dest, default=None):
        """
        Get an option from opts or from the config file
        Options from opts take precedence.
        
        :type opt: str
        :param opt: name of option to get
        :return: value of the option or None if the option is no present
        """
        attr = getattr(self.opts, opt_dest, None)
        if not default is None and attr is None:
            attr = default
        return u_obj(attr)

    def get_option_dict(self, *allowed_keys):
        """
        Get all options from opts or from the config file as a dictionary.
        Options from opts take precedence.
        @type allowed_keys: variable length arguments, names of options the dictionary will contain.
        Other options will be omitted. The function returns a dictionary with all the options
        if no allowed key is passed.
        @param allowed_keys: strings
        @return: a dictionary with options (opt. destination -> opt. value)
        """
        if allowed_keys:
            return dict((key, self.get_option(key)) for key in allowed_keys)
        else:
            return dict((key, self.get_option(key)) for key in vars(self.opts).keys())


    def has_option(self, opt):
        """
        Check if option is present
        
        :type opt: str
        :param opt: name of option to check
        :return: True if the option was set, otherwise False
        """
        return (not self.get_option(opt) is None)

    def setup_parser(self, parser):
        """
        Add custom options to the parser
        
        :note: this method should be overridden to add per-action options
        """
        self.takes_options = False

    def run(self):
        """
        Action's functionality
        
        :note: override this method to implement the actoin's functionality
        :raise NotImplementedError: if this method is not overridden
        """
        pass

    def check_options(self, validator):
        """
        Add custom option requirements
        
        :note: this method should be overridden to check for required options
        """
        return

    def error(self, error_msg):
        """
        Logs an error and prints it to stderr
        """
        error_msg = u_str(error_msg)
        error_msg = error_msg if error_msg else _('operation failed')

        _log.error("error: %s" % error_msg)
        print >> sys.stderr, error_msg


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


    def main(self, args, command_name=None, parent_usage=None):
        """
        Main execution of the action
        This method setups up the parser, parses the arguments, and calls run()
        in a try/except block, handling RestlibExceptions and general errors
        
        :warning: this method should only be overridden with care
        """
        parser = self.create_parser(command_name, parent_usage)
        self.process_options(parser, args)
        return self.run()



class Command(CommandContainer, Action):
    """
    Represents a CLI command. It is a simple action with the ability to contain
    multiple subcommands and actions.
    """

    def usage(self, command_name=None, parent_usage=None):
        """
        Usage string.
        
        :rtype: str
        :return: command's usage string
        """
        first_line = "Usage: "+self._get_usage_line(command_name, parent_usage)
        if len(self.get_command_names()) > 0:
            first_line += " <command>"

        lines = [first_line, 'Supported Commands:']
        for name in sorted(self.get_command_names()):
            lines += self.__build_command_usage_lines(name, self.get_command(name))
        return '\n'.join(lines)

    def __build_command_usage_lines(self, name, command):
        lines = []
        desc_lines = command.description.split("\n")

        lines.append('\t%-14s %s' % (name, desc_lines.pop(0)) )
        for l in desc_lines:
            lines.append('\t%-14s %s' % (" ", l) )

        return lines

    def create_parser(self, command_name=None, parent_usage=None):
        parser = super(Command, self).create_parser(command_name, parent_usage)
        parser.disable_interspersed_args()
        return parser

    def _extract_command(self, parser, args):
        if not args:
            parser.error(_('no action given: please see --help'))
        try:
            command = self.get_command(args[0])
            return command
        except:
            parser.error(_('invalid action: please see --help'))
            return None


    def main(self, args, command_name=None, parent_usage=None):
        if type(args) == str:
            args = parse_tokens(args)

        parser = self.create_parser(command_name, parent_usage)
        self.process_options(parser, args)

        self.run()
        subcommand = self._extract_command(parser, self.args)

        return subcommand.main(self.args[1:], self.args[0], self._get_usage_line(command_name, parent_usage))



# base action class -----------------------------------------------------------

class BaseAction(Action):
    """
    Action class representing a single CLI action. All actions should inherit from this class.
    Inherits from Action.

    :ivar Printer: printer.Printer instance
    """

    def __init__(self):
        super(BaseAction, self).__init__()
        self.printer = None


    def create_parser(self, command_name=None, parent_usage=None):
        parser = super(BaseAction, self).create_parser(command_name, parent_usage)
        parser.add_option('-g', dest='grep',
                        action="store_true",
                        help=_("grep friendly output"))
        parser.add_option('-v', dest='verbose',
                        action="store_true",
                        help=_("verbose, more structured output"))
        parser.add_option('-d', dest='delimiter',
                        default="",
                        help=_("column delimiter in grep friendly output, works only with option -g"))
        return parser

    def create_printer(self, strategy):
        return Printer(strategy)

    def __print_strategy(self):
        Config()
        if (self.has_option('grep') or (Config.parser.has_option('interface', 'force_grep_friendly') and Config.parser.get('interface', 'force_grep_friendly').lower() == 'true')):
            return GrepStrategy(delimiter=self.get_option('delimiter'))
        elif (self.has_option('verbose') or (Config.parser.has_option('interface', 'force_verbose') and Config.parser.get('interface', 'force_verbose').lower() == 'true')):
            return VerboseStrategy()
        else:
            return None

    def load_saved_options(self, parser):
        Config()
        if not Config.parser.has_section('options'):
            return
        for opt_name, opt_value in Config.parser.items('options'):
            opt = parser.get_option_by_name(opt_name)
            if not opt is None:
                parser.set_default(opt.get_dest(), opt_value)


    def setup_action(self, args, command_name=None, parent_usage=None):
        parser = self.create_parser(command_name, parent_usage)
        self.load_saved_options(parser)
        self.process_options(parser, args)

        self.printer = self.create_printer(self.__print_strategy())


    def main(self, args, command_name=None, parent_usage=None):
        """
        Main execution of the action
        This method setups up the parser, parses the arguments, and calls run()
        in a try/except block, handling RestlibExceptions and general errors
     
        :warning: this method should only be overridden with care
        """
        try:
            self.setup_action(args, command_name, parent_usage)
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
    elif not url_parsed.netloc and not url_parsed.path:                  # pylint: disable=E1101
        raise OptionValueError(_('option %s: invalid format') % (opt))
    return value

class KatelloOption(Option):
    """
    Option types allow to check and preprocess values of options.
    There are `6 option types <http://docs.python.org/library/optparse.html#optparse-standard-option-types>`_ that come with optparse by default.

    Our KatelloOption adds 3 more on the top of them:

    **bool**
        Parse a string and try to convert it to bool value.WW

        :allowed values:    strings "true" and "false" at any case
        :return type:       bool
        :arguments:         none 

        .. code-block:: python

            # usage:
            parser.add_option('--enable', dest='enable', type="bool")


    **list**
        Parse a string and try to tear it by a delimiter into a list of substrings.[[BR]]
        If no delimiter is found in the string the original value is returned as the only item of the list.

        :allowed values:    string (can contain the delimiter)
        :return type:       list of strings
        :arguments:         - delimiter - string that delimits the values, default is ","

        .. code-block:: python

            # usage:
            parser.add_option('--package', dest='package', type="list", delimiter=",")


    **url**
        Parses an url string that starts with a given scheme ("http" and "https" is accepted by default).
        Throws an exception if the value is not a valid url.

        :allowed values:    string with valid url path
        :return type:       string
        :arguments:         - schemes - list of strings, allowed schemes, default is ["http", "https"]

        .. code-block:: python
        
            # usage:
            parser.add_option('--feed', dest='feed', type="url", schemes=['https'])

    """


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
