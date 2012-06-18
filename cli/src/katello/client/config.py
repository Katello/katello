#
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


import os
import ConfigParser
from pwd import getpwuid

class Config(object):
    """
    The katello client configuration.
    Works as a static singleton class.

    This Config class acts as a wrapper for ConfigParser so that each class
    needing to access the config file doesn't need to keep track of the file path.
    You can simply initialize Config with 'Config()' and you have full access to a
    RawConfigParser with the config file read into the object for manipulation
    by calling methods on 'Config.parser' .

    For more detailed information on ConfigParser and its methods, please see
    http://docs.python.org/library/configparser.html .

    To save to the config file after making changes, call 'Config.save()' and the
    changes will be written to file. Please note this only saves 'options'
    section of the file storing it in the client-options.conf file.

    Config throws an Exception if 'Config.save()' is called before initializing
    the Config object.

    @cvar PATH: The absolute path to the config directory.
    @type PATH: str
    @cvar USER: The path to an alternate configuration file
        within the user's home.
    @type USER: str
    """

    FILE = 'client.conf'
    PATH = os.path.join('/etc/katello', FILE)
    USER_DIR = os.path.join(getpwuid(os.getuid())[5], '.katello')
    USER = os.path.expanduser(os.path.join(USER_DIR, FILE))
    USER_OPTIONS = os.path.expanduser(os.path.join(USER_DIR, 'client-options.conf'))

    parser = None

    def __init__(self):
        """
        Initializes a RawConfigParser and reads the configuration file into the object
        """
        if Config.parser:
            return

        Config.parser = ConfigParser.RawConfigParser()

        # read global config, user config, user options if it exists
        read_config_files = Config.parser.read([Config.PATH, Config.USER, Config.USER_OPTIONS])

        if not read_config_files:
            raise Exception('No config file was found')

        if Config.parser.has_section("DEFAULT"):
            raise Exception('Default section in configuration is not supported')

    @staticmethod
    def save():
        """
        Save the "options" section to the client-options.conf file.

        Please note other settings (other sections) are not saved!
        """
        if not Config.parser:
            raise Exception('Config.parser has not been initialized.')

        opt = ConfigParser.RawConfigParser()
        # write a comment informing user not to use this file for own settings
        opt.set('', '# = do not edit and use client.conf instead', '')
        opt.add_section('options')

        for option in Config.parser.options('options'):
            value = Config.parser.get('options', option)
            opt.set('options', option, value)

        Config.ensure_dir(Config.USER_OPTIONS)
        opt.write(open(Config.USER_OPTIONS, 'w'))

    @staticmethod
    def ensure_dir(f):
        d = os.path.dirname(f)
        if not os.path.exists(d):
            os.makedirs(d)
