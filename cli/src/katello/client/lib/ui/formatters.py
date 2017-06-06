# -*- coding: utf-8 -*-

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

import dateutil.parser


SYNC_STATES = { 'waiting':     _("Waiting"),
                'running':     _("Running"),
                'error':       _("Error"),
                'finished':    _("Finished"),
                'cancelled':   _("Canceled"),
                'canceled':    _("Canceled"),
                'timed_out':   _("Timed out"),
                'not_synced':  _("Not synced") }


def format_sync_time(sync_time):
    if sync_time is None:
        return 'never'
    else:
        return format_date(sync_time)


def format_sync_state(state):
    return SYNC_STATES[state]


def format_date(date, to_format="%Y/%m/%d %H:%M:%S"):
    """
    Format standard rails timestamp to more human readable format
    @type date: string
    @param date: arguments for the function
    @return string, formatted date
    """
    if not date:
        return ""
    t = dateutil.parser.parse(date)
    return t.strftime(to_format)


def format_sync_status(task):
    return "\n".join(task.status_messages())

def format_sync_errors(task):
    """
    Format errors in progress returned from AsyncTask
    @type errors: list
    @param errors: list of progress errors returned from AsyncTask.progress_errors()
    @return string, each error on one line
    """
    def format_progress_error(e):
        if "error" in e:
            if isinstance(e["error"], dict) and ("error" in e["error"]):
                return e["error"]["error"]
            else:
                return str(e["error"])

    def format_task_error(e):
        if isinstance(e, list) and len(e) > 0:
            return e[0]

    error_list = [format_progress_error(e) for e in task.progress_errors()]
    error_list += [format_task_error(e) for e in task.errors()]

    return "\n".join([e for e in error_list if e])


def format_task_errors(errors):
    """
    Format errors returned from AsyncTask
    @type errors: list
    @param errors: list of errors returned from AsyncTask.errors()
    @return string, each error on one line
    """
    error_list = [e[0] for e in errors if e[0]]
    return "\n".join(error_list)


def format_sub_resource(item, name_key, id_key, format_string="%s (Id: %d)"):
    name = item[name_key]
    resource_id = item[id_key]
    if resource_id is not None:
        return format_string % (name, resource_id)
    else:
        return "None"


def stringify_custom_info(list_custom_info):
    arr = []
    for info in list_custom_info:
        arr.append("%s: %s" % (info["keyname"], info["value"]))
    return "[ %s ]" % ", ".join(arr)
