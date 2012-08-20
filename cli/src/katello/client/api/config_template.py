#
# Copyright 2012 Red Hat, Inc.
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


def slice_dict(d, *key_list):
    return dict((k, d.get(k)) for k in key_list if d.get(k))

class ConfigTemplateAPI(KatelloAPI):


    def list(self, queries):
        """
        list config template

        :type  data['search']: string
        :param data['search']: filter results

        :type  data['order']: string
        :param data['order']: sort results
        """
        path = "/api/config_templates"
        queries = slice_dict(queries, 'search', 'order')
        return self.server.GET(path, queries)[1]


    def show(self, id):
        """
        show config template
        """
        path = "/api/config_templates/%s" % (id)
        return self.server.GET(path)[1]


    def create(self, data):
        """
        create config template

        :type  data['name']: string
        :param data['name']: template name

        :type  data['template']: string
        :param data['template']:
        :type  data['snippet']: string
        :param data['snippet']:
        :type  data['audit_comment']: string
        """
        path = "/api/config_templates"
        data = slice_dict(data, 'name', 'template', 'snippet', 'audit_comment', 'template_kind_id', 'template_combinations_attributes', 'operatingsystem_ids')
        return self.server.POST(path, {"config_template": data})[1]


    def update(self, id, data):
        """
        update config template

        :type  data['name']: string
        :param data['name']: template name

        :type  data['template']: string
        :param data['template']:
        :type  data['snippet']: string
        :param data['snippet']:
        :type  data['audit_comment']: string
        :param data['audit_comment']:
        :type  data['template_kind_id']: string
        :param data['template_kind_id']: not relevant for snippet

        :type  data['template_combinations_attributes']: string
        :param data['template_combinations_attributes']: Array of template combinations (hostgroup_id, environment_id)

        :type  data['operatingsystem_ids']: string
        :param data['operatingsystem_ids']: Array of operating systems ID to associate the template with
        """
        path = "/api/config_templates/%s" % (id)
        data = slice_dict(data, 'name', 'template', 'snippet', 'audit_comment', 'template_kind_id', 'template_combinations_attributes', 'operatingsystem_ids')
        return self.server.PUT(path, {"config_template": data})[1]


    def revision(self, queries):
        """
        revision config template

        :type  data['version']: string
        :param data['version']: template version
        """
        path = "/api/config_templates/revision"
        queries = slice_dict(queries, 'version')
        return self.server.GET(path, queries)[1]


    def destroy(self, id):
        """
        destroy config template
        """
        path = "/api/config_templates/%s" % (id)
        return self.server.DELETE(path)[1]


    def build_pxe_default(self):
        """
        build_pxe_default config template
        """
        path = "/api/config_templates/build_pxe_default"
        return self.server.GET(path)[1]
