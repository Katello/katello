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


import os
from iniparse import INIConfig
from iniparse.config import update_config
from pwd import getpwuid

class ConfigFileError(Exception):
    pass

class Config(object):

    FILE = 'export.conf'
    USER_DIR = os.path.join(getpwuid(os.getuid())[5], '.katello')
    USER = os.path.expanduser(os.path.join(USER_DIR, FILE))

    values = None

    def __init__(self):
        """
        Initializes a RawConfigParser and reads the configuration file into the object
        """
        if Config.values:
            return

        Config.values = INIConfig()

        # Set the defaults
        Config.values.server.url = ''
        Config.values.server.username = ''
        Config.values.server.password = ''
        Config.values.export.directory = ''
        Config.values.export.outputformat = 'json'
        Config.values.activationkey.environment = 'Dev'
        Config.values.activationkey.includedisabled = 'False'
        Config.values.mapping.roles = ''
        Config.values.mapping.orgs = ''

        if os.path.exists(Config.USER):
            user_settings = INIConfig(open(Config.USER))
            update_config(Config.values, user_settings)

    @staticmethod
    def get_value(name, default=None):
        if (Config.values[name]):
            return Config.values[name]
        else:
            return default


