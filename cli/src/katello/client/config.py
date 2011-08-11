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
    Treated at a static class.
    @cvar PATH: The absolute path to the config directory.
    @type PATH: str
    @cvar USER: The path to an alternate configuration file
        within the user's home.
    @type USER: str
    @cvar ALT: The environment variable with a path to an alternate
        configuration file.
    @type ALT: str
    """

    FILE = 'client.conf'
    PATH = os.path.join('/etc/katello', FILE)
    USER = os.path.join('~/.katello', FILE)
    ALT = 'KATELLO_CLIENT_OVERRIDE'
    
    parser = None
    
    def __init__(self):
        """
        Initializes a ConfigParser and reads the configuration file into the object
        """
        if Config.parser:
            return
        
        Config.parser = ConfigParser.RawConfigParser()
        
        Config.parser.readfp(open(Config.PATH, 'r'), Config.PATH)
    
    @staticmethod
    def save():
        """
        Save the current state of the ConfigParser to file
        """
        if not Config.parser:
            raise Exception('Config.parser has not been initialized.')
        
        # only writes to /etc/katello/client.conf
        Config.parser.write(open(Config.PATH, 'w'))
        