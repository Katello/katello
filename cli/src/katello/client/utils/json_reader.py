# -*- coding: utf-8 -*-

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

import json
from collections import defaultdict

class JSONReader(object):

    def __init__(self, filename):
        super(JSONReader, self).__init__()
        self.data_file = open(filename, 'rb')
        self.json_data = iter(json.load(self.data_file))

    def __iter__(self):
        return self

    def next(self):
        next_row = self.json_data.next()
        return_item = defaultdict(str)
        for key, value in next_row.items():
            if (type(value) is list):
                return_item[key] = ",".join(value)
            else:
                return_item[key] = str(value)
        return return_item
