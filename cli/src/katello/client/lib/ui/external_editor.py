# -*- coding: utf-8 -*-

# Copyright © 2013 Red Hat, Inc.
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

import os
import tempfile
from subprocess import call
from katello.client.lib.control import system_exit

class Editor():

    DEFAULT_EDITOR = 'vim'

    editor = None

    def __init__(self, editor=None):
        self.editor = editor


    def __get_editor_cmd(self):
        return self.editor or os.environ.get('EDITOR', self.DEFAULT_EDITOR)


    def open_file(self, filename):
        editor = self.__get_editor_cmd()
        try:
            call([editor, filename])
        except OSError:
            system_exit(os.EX_OSERR,
                _("Editor '%s' not found on the system. You can override the default "
                "editor by setting EDITOR environment variable.") % editor)


    def open_text(self, text):

        with tempfile.NamedTemporaryFile(suffix=".tmp") as tmp_f:
            tmp_f.write(text)
            tmp_f.flush()

            self.open_file(tmp_f.name)

            tmp_f.seek(0)
            return tmp_f.read()

