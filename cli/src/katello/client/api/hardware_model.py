# -*- coding: utf-8 -*-
#
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

from urllib import quote

from katello.client.api.base import KatelloAPI
from katello.client.lib.utils.data import slice_dict


class HardwareModelAPI(KatelloAPI):

    @classmethod
    def __path(cls, model_id=None):
        if model_id is None:
            return "/api/hardware_models/"
        else:
            return "/api/hardware_models/%s/" % quote(str(model_id))

    def list(self):
        """
        list hardware model
        """
        return self.server.GET(self.__path())[1]


    def show(self, model_id):
        """
        show hardware model

        :type  model_id: string
        :param model_id: hardware model name
        """
        return self.server.GET(self.__path(model_id))[1]


    def create(self, data):
        """
        create hardware model

        :type  data['name']: string
        :param data['name']:
        :type  data['info']: string
        :param data['info']:
        :type  data['vendor_class']: string
        :param data['vendor_class']:
        :type  data['hardware_model']: string
        :param data['hardware_model']:
        """
        data = slice_dict(data, 'name', 'info', 'vendor_class', 'hardware_model')
        return self.server.POST(self.__path(), {"hardware_model": data})[1]


    def update(self, model_id, data):
        """
        update hardware model

        :type  model_id: string
        :param model_id: hardware model name
        :type  data: hash
        :param data: hardware model info
        :type  data['name']: string
        :param data['name']:
        :type  data['info']: string
        :param data['info']:
        :type  data['vendor_class']: string
        :param data['vendor_class']:
        :type  data['hardware_model']: string
        :param data['hardware_model']:
        """
        data = slice_dict(data, 'name', 'info', 'vendor_class', 'hardware_model')
        return self.server.PUT(self.__path(model_id), {"hardware_model": data})[1]


    def destroy(self, model_id):
        """
        destroy hardware model

        :type  model_id: string
        :param model_id: hardware model name
        """
        return self.server.DELETE(self.__path(model_id))[1]

