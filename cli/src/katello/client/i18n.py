# Copyright (c) 2011 Red Hat, Inc.
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
import sys

# Localization domain:
APP = 'katello-cli'
# Directory where translations are deployed:
DIR = '/usr/share/locale/'

def configure_i18n():
    """
    Configure internationalization for the application.
    """
    import locale
    import gettext
    try:
        locale.setlocale(locale.LC_ALL, '')
    except locale.Error:
        locale.setlocale(locale.LC_ALL, 'C')
    gettext.bindtextdomain(APP, DIR)
    gettext.textdomain(APP)
    gettext.bind_textdomain_codeset(APP, 'utf-8')

