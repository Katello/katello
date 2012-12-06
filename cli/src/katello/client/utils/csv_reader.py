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

import csv
from collections import defaultdict

class CSVReader(object):

    def __init__(self, filename):
        super(CSVReader, self).__init__()
        self.data_file = csv.reader(open(filename, 'rb'), quotechar='"', skipinitialspace=True)
        self.headers = self.data_file.next()

    def __iter__(self):
        return self

    def next(self):
        next_row = self.data_file.next()
        if len(next_row) == 0:
            raise StopIteration("Empty row found")

        return_item = defaultdict(str)
        loc = 0
        for header in self.headers:
            return_item[header] = next_row[loc]
            loc += 1
        return return_item
