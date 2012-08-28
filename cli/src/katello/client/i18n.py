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
import gettext
import locale

from katello.client.utils.encoding import encode_stream

# Localization domain:
APP = 'katello-cli'
# Directory where translations are deployed:
DIR = '/usr/share/locale/'
# Encoding of the locales:
ENCODING = 'utf-8'


def force_encoding(encoding):
    """
    Force locale to use specific encoding and bind output streams to use it.
    """
    current_locale = locale.getlocale(locale.LC_ALL)[0] or locale.getdefaultlocale()[0]
    locale.setlocale(locale.LC_ALL, str(current_locale)+'.'+str(encoding))
    sys.stdout = encode_stream(sys.stdout, encoding)
    sys.stderr = encode_stream(sys.stderr, encoding)


def configure_i18n():
    """
    Configure internationalization for the application.
    """
    try:
        locale.setlocale(locale.LC_ALL, '')
    except locale.Error:
        locale.setlocale(locale.LC_ALL, 'C')

    if locale.getpreferredencoding().lower() != ENCODING.lower():
        force_encoding(ENCODING)

    # this will set _() to ugettext() globaly
    gettext.install(APP, DIR, True, ENCODING)
