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
        returns a ConfigParser with the configuration file read into the object
        """
        if not Config.parser:
            Config.parser = ConfigParser.RawConfigParser()
            
            # this file must exist and be populated
            Config.parser.readfp(open(Config.PATH), Config.PATH)
            
            # then read in files that may or may not exist.
            # 1. look for environment variable describing files's location
            # 2. look for config file in /home/<user>/.katello/
            optionals = []
            env_var = os.environ.get(Config.ALT)
            
            # RawConfigParser.read() throws NoneType exception if any arguments happen to be None
            if env_var is not None: optionals.append(env_var)
            
            optionals.append(os.path.expanduser(Config.USER))
            Config.parser.read(optionals)
