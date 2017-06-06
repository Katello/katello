# -*- coding: utf-8 -*-

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

import os
import sys
from katello.client.i18n_optparse import OptionParser, OptionParserExitError
from M2Crypto import SSL
from socket import error as SocketError
from urlparse import urlparse

from katello.client.config import Config
from katello.client.api.utils import ApiDataError
from katello.client.lib.control import parse_tokens, SystemExitRequest
from katello.client.lib.ui.printer import Printer, GrepStrategy, VerboseStrategy
from katello.client.lib.utils.option_validator import OptionValidator
from katello.client.lib.utils.encoding import u_str, u_obj
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

class CommandException(Exception):
    pass

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
        :raises CommandException: if the command was not found
        :return: command or action registered under the given name
        """
        if name in self.__subcommands:
            return self.__subcommands[name]
        raise CommandException(_("Command not found"))



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
            first_line += " <{0}>".format(_("options"))
        return first_line

    def usage(self, command_name=None, parent_usage=None):
        """
        Usage string.

        :rtype: str
        :return: command's usage string
        """
        return _("Usage: ") + self._get_usage_line(command_name, parent_usage)

    # pylint: disable=R0201
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

    @classmethod
    def create_validator(cls, parser, opts, args):
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
        if not allowed_keys:
            allowed_keys = vars(self.opts).keys()
        return dict((key, self.get_option(key)) for key in allowed_keys if self.get_option(key) is not None)

    def has_option(self, opt):
        """
        Check if option is present

        :type opt: str
        :param opt: name of option to check
        :return: True if the option was set, otherwise False
        """
        return (not self.get_option(opt) is None)

    # pylint: disable=W0613
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

        _log.error("error: " + error_msg)
        print >> sys.stderr, error_msg


    def process_options(self, parser, args):
        self.opts, self.args = parser.parse_args(args)

        validator = self.create_validator(parser, self.opts, self.args)
        self.check_options(validator)
        self.__process_option_errors(parser, validator.opt_errors)

    @classmethod
    def __process_option_errors(cls, parser, errors):
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
        first_line = _("Usage: ") + self._get_usage_line(command_name, parent_usage)
        if len(self.get_command_names()) > 0:
            first_line += " <{0}>".format(_("command"))

        lines = [first_line, _("Supported Commands:")]
        for name in sorted(self.get_command_names()):
            lines += self.__build_command_usage_lines(name, self.get_command(name))
        return '\n'.join(lines)

    @classmethod
    def __build_command_usage_lines(cls, name, command):
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
        except CommandException:
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
        parser.add_option('--noheading', dest='noheading',
                        action="store_true", default=False,
                        help=_("Suppress any heading output. Useful if grepping the output."))
        return parser

    def create_printer(self, strategy):
        return Printer(strategy, noheading=self.get_option('noheading'))

    def __print_strategy(self):
        Config()
        if (self.has_option('grep') or (Config.parser.has_option('interface', 'force_grep_friendly') \
            and Config.parser.get('interface', 'force_grep_friendly').lower() == 'true')):
            return GrepStrategy(delimiter=self.get_option('delimiter'))
        elif (self.has_option('verbose') or (Config.parser.has_option('interface', 'force_verbose') \
            and Config.parser.get('interface', 'force_verbose').lower() == 'true')):
            return VerboseStrategy()
        else:
            return None

    @classmethod
    def load_saved_options(cls, parser):
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

    # pylint: disable=R0911,R0915
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
            print _("You have: [%(expectedHost)s] configured but got: [%(actualHost)s] from the server.") \
                % {'expectedHost':wh.expectedHost, 'actualHost':wh.actualHost}
            print ""
            print _("Please correct the host in the /etc/katello/client.conf file")
            sys.exit(1)

        except ServerRequestError, re:
            try:
                if "displayMessage" in re.args[1]:
                    msg = re.args[1]["displayMessage"]
                elif re.args[0] == 401:
                    msg = _("Invalid credentials or unable to authenticate")
                elif re.args[0] == 500:
                    msg = _("Server is returning 500 - try later")
                elif "errors" in re.args[1]:
                    msg = ", ".join(re.args[1]["errors"])
                elif "message" in re.args[1]:
                    msg = re.args[1]["message"]
                else:
                    msg = str(re.args[1])
            except IndexError:
                msg = re.args[1]
            except:  # pylint: disable=W0702
                msg = _("Unknown error: ") + str(re)

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
                _log.info(u_str(msg))
            else:
                out = sys.stderr

            if msg != "":
                print >> out, msg
            return ser.args[0]

        except KeyboardInterrupt:
            return os.EX_NOUSER

        print ''






# optparse type extenstions --------------------------------------------------


# pylint: disable=W0613
def check_bool(option, opt, value):
    if value.lower() in ["true","false"]:
        return (value.lower() == "true")
    else:
        raise OptionValueError(_("option %(opt)s: invalid boolean value: %(value)r") % {'opt':opt, 'value':value})

def check_insensitive_choice(option, opt, value):
    if option.case_sensitive is False:
        value = str(value).lower()
        choices = [str(c).lower() for c in option.choices]
    else:
        choices = option.choices

    if value in choices:
        return value
    else:
        choices = ", ".join(option.choices)
        raise OptionValueError(
            _("option %(opt)s: invalid choice: %(value)r (choose from %(choices)s)")
            % {'opt':opt, 'value':value, 'choices':choices})

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
        raise OptionValueError(_('option %(opt)s: has to start with %(formatted_schemes)s') \
            % {'opt':opt, 'formatted_schemes':formatted_schemes})
    elif not url_parsed.netloc and not url_parsed.path:                  # pylint: disable=E1101
        raise OptionValueError(_('option %s: invalid format') % (opt))
    return value

def check_ip(option, opt, value):

    def raise_exception():
        raise OptionValueError(_('option %s: invalid ip address format') % (opt))

    parts = value.strip().split('.')
    if len(parts) != 4:
        raise_exception()

    for s in parts:
        try:
            if int(s)<0 or int(s)>255:
                raise_exception()
        except ValueError:
            raise_exception()
    return value.strip()


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


    **choice**
        Extension of original optparse choice.[[BR]]
        Allows case insensitive comparison.

        :arguments: - case_sensitive - sensitivity switch flag. Default value is True.

        .. code-block:: python

            # usage:
            parser.add_option('--select_one', dest='select_one', type="choice", choices=['A', 'B', 'C'], case_sensitive=False)


    **url**
        Parses an url string that starts with a given scheme ("http" and "https" is accepted by default).
        Throws an exception if the value is not a valid url.

        :allowed values:    string with valid url path
        :return type:       string
        :arguments:         - schemes - list of strings, allowed schemes, default is ["http", "https"]

        .. code-block:: python

            # usage:
            parser.add_option('--feed', dest='feed', type="url", schemes=['https'])

    **ip**
        Parses ipv4 addresses.

        :allowed values:    ipv4 address
        :return type:       string
        :arguments:         none

    """


    TYPE_CHECKER = copy(Option.TYPE_CHECKER)
    TYPES = copy(Option.TYPES)
    ATTRS = copy(Option.ATTRS)

    TYPE_CHECKER["bool"] = check_bool
    TYPES = TYPES + ("bool", )

    TYPE_CHECKER["list"] = check_list
    TYPES += ("list", )
    ATTRS += ["delimiter", ]

    TYPE_CHECKER["choice"] = check_insensitive_choice
    ATTRS += ["case_sensitive", ]

    TYPE_CHECKER["url"] = check_url
    TYPES += ("url", )
    ATTRS += ["schemes", ]

    TYPE_CHECKER["ip"] = check_ip
    TYPES += ("ip", )

    def get_name(self):
        return self.get_opt_string().lstrip('-')

    def get_dest(self):
        return self.dest
