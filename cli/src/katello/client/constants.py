#
# String constants for the katello CLI
#
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
#


STATUS_DETAIL_SUCCESS = """
     Name          \t%-20s
     Result        \t%-20s
     Duration      \t%-20s"""

STATUS_DETAIL_FAIL = """
     Name          \t%-20s
     Result        \t%-20s
     Message       \t%-20s"""

STATUS_INFO = """
Status             \t%-25s"""

SELECTION_QUERY = """
  'a'   \t : select all
  'x:y' \t : select a range eg:1:3
  <sel> \t : select value in range (1-%s) to toggle selection
  'y'   \t : confirm selection
  'c'   \t : clear selections
  'q'   \t : abort the repo creation
"""

PROMOTION = 'PROMOTION'
DELETION = 'DELETION'

# Help string for optparser
OPT_HELP_PROMOTION = _("changeset type promotion: pushes changes to the next environment [DEFAULT]")
OPT_HELP_DELETION = _("changeset type deletion: deletes items in changeset from current environment")
OPT_ERR_PROMOTION_OR_DELETE = _("specify either --promotion or --deletion but not both")


