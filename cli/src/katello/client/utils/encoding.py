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


def u_str(value, encoding='utf-8'):
    """
    Casts value to unicode string.
    """
    if not isinstance(value, basestring):
        value = str(value)
    if not isinstance(value, unicode):
        value = unicode(value, encoding)
    return value


def u_obj(data, encoding='utf-8'):
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
