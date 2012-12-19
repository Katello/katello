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

from katello.client.api.base import KatelloAPI
from katello.client.core.utils import slice_dict


class ${resource.name(True, True)}API(KatelloAPI):

% for m in resource.methods():

    def ${m.name(True)}(${", ".join(m.arguments())}):
        """
${doc.generate(m, " "*8)}
        """
        path = ${m.path()}
        % if m.accepts_data():
        ${m.data_var_name()} = slice_dict(${m.data_var_name()}, ${", ".join(["'"+k+"'" for k in m.data_keys()] )})
            % if m.param_nest():
        return self.server.${m.http_method()}(path, {"${m.param_nest().name()}": ${m.data_var_name()}})[1]
            % else:
        return self.server.${m.http_method()}(path, ${m.data_var_name()})[1]
            % endif
        % else:
        return self.server.${m.http_method()}(path)[1]
        % endif

% endfor
