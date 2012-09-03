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
from logging import root, DEBUG
from traceback import format_exc

from optparse import OptionGroup, SUPPRESS_HELP
from katello.client.i18n_optparse import OptionParserExitError
from katello.client.utils.encoding import u_str
from katello.client.core.base import Command
from katello.client.config import Config
from katello.client.logutil import getLogger, logfile
from katello.client import server

from katello.client.server import BasicAuthentication, SSLAuthentication, NoAuthentication


_log = getLogger(__name__)

def opt_parser_add_product(parser, required=None):
    """ Add to the instance of optparse option --product"""
    if required:
        required = _(" (required)")
    else:
        required = ''
    parser.add_option('--product', dest='product',
                      help=_('product name e.g.: "Red Hat Enterprise Linux Server"%s' % required))


def opt_parser_add_org(parser, required=None):
    """ Add to the instance of optparse option --org"""
    if isinstance(required, basestring):
        pass # required already contains string
    elif required:
        required = _(" (required)")
    else:
        required = ''
    parser.add_option('--org', dest='org',
                      help=_('name of organization e.g.: ACME_Corporation%s' % required))

def opt_parser_add_environment(parser, required=None, default=''):
    """ Add to the instance of optparse option --environment"""
    if isinstance(required, basestring):
        pass # required already contains string
    elif required:
        required = _(" (required)")
    else:
        required = ''
    if default:
        default = _(" (default: %s)") % default
    parser.add_option('--environment', dest='environment',
                      help=_('environment name e.g.: production%s%s' % (required, default)))

class OptionException(Exception):
    """
    Exception to be used, when value of an option is not valid e.g. not found
    """
    pass

class KatelloError(Exception):
    """
    User-friendly exception wrapper (used for stderr output).
    """
    def __init__(self, message, exception):
        super(KatelloError, self).__init__(message, exception)
        self.message = message
        self.exception = exception

    def __str__(self):
        return repr(self.message) + ": " + repr(self.exception)


class KatelloCLI(Command):
    """
    Katello command line tool class.
    """

    def __init__(self):
        super(KatelloCLI, self).__init__()
        self._server = None
        self._username = None
        self._password = None
        self._certfile = None
        self._keyfile = None

    def setup_parser(self, parser):
        """
        Add options to the command line parser.
        @note: this method may be overridden to define new options
        """
        parser.add_option("-v", "--version", action="store_true", default=False,
                                dest="version",  help=_('prints version information'))
        parser.add_option("-d", "--debug", action="store_true", default=False,
                                dest="debug",  help=_('send debug information into logs'))

        credentials = OptionGroup(parser, _('Katello User Account Credentials'))
        credentials.add_option('-u', '--username', dest='username',
                                default=None, help=_('account username'))
        credentials.add_option('-p', '--password', dest='password',
                                default=None, help=_('account password'))
        credentials.add_option('--cert-file', dest='certfile',
                                default=None, help=SUPPRESS_HELP)
        credentials.add_option('--key-file', dest='keyfile',
                                default=None, help=SUPPRESS_HELP)
        parser.add_option_group(credentials)


        Config()
        server_opt = OptionGroup(parser, _('Katello Server Information'))
        host = Config.parser.get('server', 'host') or 'localhost.localdomain'
        server_opt.add_option('--host', dest='host', default=host,
                          help=_('katello server host name (default: %s)') % host)
        port = Config.parser.get('server', 'port') or '443'
        server_opt.add_option('--port', dest='port', default=port,
                          help=SUPPRESS_HELP)
        scheme = Config.parser.get('server', 'scheme') or 'https'
        server_opt.add_option('--scheme', dest='scheme', default=scheme,
                          help=SUPPRESS_HELP)
        path = Config.parser.get('server', 'path') or '/katello/api'
        server_opt.add_option('--path', dest='path', default=path,
                          help=SUPPRESS_HELP)
        parser.add_option_group(server_opt)

    def setup_server(self):
        """
        Setup the active server connection.
        """
        host = self.opts.host
        port = self.opts.port
        scheme = self.opts.scheme
        path = self.opts.path
    
        self._server = server.KatelloServer(host, int(port), scheme, path, self.__server_locale())
        server.set_active_server(self._server)

    @classmethod
    def __server_locale(cls):
        """
        Take system locale and convert it to server locale
        Eg. en_US -> en-us
        """
        import locale
        loc = locale.getlocale(locale.LC_ALL)[0] or locale.getdefaultlocale()[0]
        if loc is not None:
            return loc.lower().replace('_', '-')
        else:
            return loc

    def setup_credentials(self):
        """
        Setup up request credentials with the active server.
        """
        self._username = self._username or self.opts.username
        self._password = self._password or self.opts.password

        self._certfile = self._certfile or self.opts.certfile
        self._keyfile = self._keyfile or self.opts.keyfile

        if None not in (self._username, self._password):
            self._server.set_auth_method(BasicAuthentication(self._username, self._password))
        elif None not in (self._certfile, self._keyfile):
            self._server.set_auth_method(SSLAuthentication(self._certfile, self._keyfile))
        else:
            self._server.set_auth_method(NoAuthentication())

    # pylint: disable=W0221
    def error(self, exception, errorMsg = None):
        msg = errorMsg if errorMsg else u_str(exception)
        print >> sys.stderr, "error: %s (more in the log file %s)" % (msg, logfile())
        _log.error(u_str(exception))
        _log.error(format_exc(exception))

    def run(self):
        global _log
        self.setup_server()
        self.setup_credentials()
        if self.get_option('version'):
            self.args = ["version"]
        if self.get_option('debug'):
            root.setLevel(DEBUG)

    def main(self, args, command_name=None, parent_usage=None):
        try:
            ret_code = super(KatelloCLI, self).main(args, command_name, parent_usage)
            return ret_code if ret_code else os.EX_OK

        except OptionParserExitError, opee:
            return opee.args[0]

        except KatelloError, ex:
            self.error(ex, ex.message)
            return 1

        except Exception, ex:
            # for all the errors see ~/.katello/client.log or /var/log/katello/client.log
            self.error(ex)
            return 1
