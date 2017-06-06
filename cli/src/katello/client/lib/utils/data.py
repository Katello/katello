# -*- coding: utf-8 -*-
#
# Katello User actions
# Copyright 2013 Red Hat, Inc.
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
from katello.client.lib.control import system_exit


def is_valid_record(rec):
    """
    Checks if record returned from server has been saved.
    @type rec: Object
    @param rec: record returned from server
    @return True if record contains created_at field with value.
    """
    if type(rec)==type(dict()) and 'created_at' in rec:
        return (rec['created_at'] != None)
    elif type(rec)==type(dict()) and 'created' in rec:
        return (rec['created'] != None)
    else:
        return False


def test_record(rec, success_msg, failure_msg):
    """
    Test if a record is valid, and exit with a proper return code and a message.
    @type rec: dictionary
    @param rec: record returned from server
    @type success_msg: string
    @param success_msg: success message
    @type failure_msg: string
    @param failure_msg: failure message
    """
    if is_valid_record(rec):
        system_exit(os.EX_OK, success_msg)
    else:
        system_exit(os.EX_DATAERR, failure_msg)


def unnest(rec, *path):
    """
    Unnests inner values in a dictionary according to key path.
    If the rec is a tuple or a list then unnesting is applied
    to its items.
    Eg.
        >>> example_dict = {'a': {'b': {'c': 'the_value'}}}
        >>> unnest(example_dict, "a", "b")
        {'c': 'the_value'}

    @param rec: record to unnest
    @type rec: dict, list or tuple of dicts
    @param *path: key path in the dictionary
    @rtype: dict, list or tupple according to type of rec
    """
    if isinstance(rec, list):
        return [unnest(item, *path) for item in rec]
    elif isinstance(rec, tuple):
        return (unnest(item, *path) for item in rec)
    else:
        assert isinstance(rec, dict)
        return reduce(dict.get, path, rec)


def unnest_one(rec):
    """
    Unnest one level of a dict. Takes first key returned by .keys()
    and unnests the value saved in the dict for that key.
    If the rec is a tuple or a list then unnesting is applied
    to its items.
    Eg.
        >>> example_dict = {'a': {'b': {'c': 'the_value'}}}
        >>> unnest_one(example_dict)
        {'b': {'c': 'the_value'}}

    @param rec: record to unnest
    @type rec: dict, list or tuple of dicts
    @rtype: dict, list or tupple according to type of rec
    """
    if isinstance(rec, (list, tuple)):
        if len(rec) > 0 and len(rec[0].keys()) > 0:
            return unnest(rec, rec[0].keys()[0])
        return rec
    else:
        assert isinstance(rec, dict)
        assert len(rec) > 0
        return unnest(rec, rec.keys()[0])


def update_dict_unless_none(d, key, value):
    """
    Update value for key in dictionary only if the value is not None.
    """
    if value != None:
        d[key] = value
    return d


def slice_dict(orig_dict, *key_list, **kw_args):
    if kw_args.get('allow_none', True):
        return dict((key, orig_dict[key]) for key in key_list if key in orig_dict)
    else:
        return dict((key, orig_dict[key]) for key in key_list if key in orig_dict and orig_dict[key] is not None)
