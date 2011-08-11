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
    changes will be written to file.

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
    USER = os.path.expanduser(os.path.join('~/.katello', FILE))
    
    parser = None
    
    def __init__(self):
        """
        Initializes a RawConfigParser and reads the configuration file into the object
        """
        if Config.parser:
            return
        
        Config.parser = ConfigParser.RawConfigParser()
        
        # read global configuration first
        Config.parser.readfp(open(Config.PATH, 'r'), Config.PATH)
        if os.path.exists(Config.USER):
            Config.parser.readfp(open(Config.USER, 'r'), Config.USER)
    
    @staticmethod
    def save():
        """
        Save the current state of the RawConfigParser to file
        """
        if not Config.parser:
            raise Exception('Config.parser has not been initialized.')
        
        # only writes to /etc/katello/client.conf
        Config.parser.write(open(Config.PATH, 'w'))
