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


def get_abs_path(path):
    """
    Return absolute path with .. and ~ resolved
    @type path: string
    @param path: relative path
    """
    path = os.path.expanduser(path)
    path = os.path.abspath(path)
    return path


def convert_to_mime_type(type_in, default=None):
    available_mime_types = {
        'text': 'text/plain',
        'csv':  'text/csv',
        'html': 'text/html',
        'pdf':  'application/pdf'
    }

    return available_mime_types.get(type_in, available_mime_types.get(default))


def attachment_file_name(headers, default):
    content_disposition = [h for h in headers if h[0].lower() == 'content-disposition']

    if len(content_disposition) > 0:
        filename = content_disposition[0][1].split('filename=')
        if len(filename) < 2:
            return default
        if filename[1][0] == '"' or filename[1][0] == "'":
            return filename[1][1:-1]
        return filename

    return default


def save_report(report, filename):
    f = open(filename, 'w')
    f.write(report)
    f.close()
