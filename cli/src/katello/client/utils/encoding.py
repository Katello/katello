# -*- coding: utf-8 -*-
#
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

import collections
import codecs
import sys


def encode_stream(stream, encoding='utf-8'):
    """
    Wrap a file stream with writer that uses the specified encoding.
    """
    if isinstance(stream, file):
        return codecs.getwriter(encoding)(stream)
    else:
        return stream


def fix_io_encoding():
    """
    Force utf-8 if no encoding is set for output streams.
    This can happen when the command is executed in a subshell.
    We use utf-8 as all our server-side data are utf-8 encoded.
    """
    if sys.stdout.encoding == None:
         sys.stdout = encode_stream(sys.stdout)
    if sys.stderr.encoding == None:
         sys.stderr = encode_stream(sys.stderr)


def u_str(value):
    """
    Casts value to unicode string.
    """
    if not isinstance(value, basestring):
        value = str(value)
    if not isinstance(value, unicode):
        value = unicode(value, 'utf-8')
    return value


def u_obj(data):
    """
    Casts all strings in object 'data' to unicode.
    """
    if isinstance(data, basestring):
        return u_str(data)

    elif isinstance(data, collections.Mapping):
        return dict(map(u_obj, data.iteritems()))

    elif isinstance(data, collections.Iterable):
        return type(data)(map(u_obj, data))

    else:
        return data
