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

import re
import sys
from katello.client.config import Config


def get_katello_mode():
    Config()
    path = Config.parser.get('server', 'path') if Config.parser.has_option('server', 'path') else ''
    if "headpin" in path or "sam" in path:
        return "headpin"
    else:
        return "katello"


class SystemExitRequest(Exception):
    """
    Exception to indicate a system exit request. Introduced to
    The arguments are [0] the response status as an integer and
    [1] a list of error messages.
    """
    pass


def system_exit(code, msgs=None):
    """
    Raise a system exit request exception with a return code and optional message(s).
    Saves a few lines of code. Exception is handled in command's main method. This
    allows not to exit the cli but only skip out of the command when running in shell mode.
    @type code: int
    @param code: code to return
    @type msgs: str or list or tuple of str's
    @param msgs: messages to display
    """
    assert msgs is None or isinstance(msgs, (basestring, list, tuple))
    lstMsgs = []
    if msgs:

        if isinstance(msgs, basestring):
            lstMsgs.append(msgs)
        elif isinstance(msgs, tuple):
            lstMsgs = list(msgs)
        else:
            lstMsgs = msgs

    raise SystemExitRequest(code, lstMsgs)


def parse_tokens(tokenstring):
    """
    Parse string as if it was command line parameters.
    @type tokenstring: string
    @param tokenstring: string with command line tokens
    @return List of tokens
    """
    from katello.client.cli.base import KatelloError

    tokens = []
    try:
        pattern = r'--?\w+|=?"[^"]*"|=?\'[^\']*\'|=?[^\s]+'

        for tok in (re.findall(pattern, tokenstring)):

            if tok[0] == '=':
                tok = tok[1:]
            if tok[0] == '"' or tok[0] == "'":
                tok = tok[1:-1]

            tokens.append(tok)
        return tokens
    except Exception, e:
        raise KatelloError("Unable to parse options", e), None, sys.exc_info()[2]


