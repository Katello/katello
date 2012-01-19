#
# Katello Organization actions
# Copyright (c) 2010 Red Hat, Inc.
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
import re
import time, datetime
from gettext import gettext as _


class DateTimeFormatException(Exception):
    pass

class DateTimeFormatter():

    time_re = "([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]"
    timezone_re = "[+-][0-9]{2}:[0-9]{2}|Z"
    year_re = "[0-9]{4}"
    month_re = "(0[1-9]|1[0-2])"
    day_re = "(0[1-9]|[1-2][0-9]|3[0-1])"
    date_re = "%s-%s-%s" % (year_re, month_re, day_re)

    def time_valid(self, time):
        return re.compile("^%s(%s)?$" % (self.time_re, self.timezone_re)).match(time) != None

    def date_valid(self, time):
        return re.compile("^%s$" % self.date_re).match(time) != None

    def contains_zone(self, time):
        return re.compile(".*%s$" % self.timezone_re).match(time) != None

    def build_datetime(self, date, time):
        if not self.time_valid(time):
            raise DateTimeFormatException(_("Time format is invalid. Required: HH:MM:SS[+HH:MM]"))
        if not self.date_valid(date):
            raise DateTimeFormatException(_("Date format is invalid. Required: YYYY-MM-DD"))

        if self.contains_zone(time):
            return date+"T"+time
        else:
            return date+"T"+time+self.local_timezone()

    def local_timezone(self):
        t = time.time()
        loc_time = time.localtime(t)
        utc_time = time.gmtime(t)

        shift = loc_time.tm_hour - utc_time.tm_hour
        return "%+03i:00" % shift
