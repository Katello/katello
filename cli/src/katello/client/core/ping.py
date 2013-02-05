#
# Katello Organization actions
# Copyright (c) 2012 Red Hat, Inc.
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


from katello.client.api.ping import PingAPI
from katello.client.core.base import BaseAction
from katello.client.lib.ui.printer import batch_add_columns


# base ping action --------------------------------------------------------

class PingAction(BaseAction):

    def __init__(self):
        super(PingAction, self).__init__()
        self.api = PingAPI()



# ping actions ------------------------------------------------------------

class Status(PingAction):

    description = _('get the status of the katello server')


    def run(self):

        status = self.api.ping()

        batch_add_columns(self.printer, {'status': _("Status")}, {'service': _("Service")}, \
            {'result': _("Result")}, {'duration': _("Duration")}, {'message': _("Message")})
        self.printer.set_header(_("Katello Status"))

        statusList = self.__statusToList(status)
        self.printer.print_items(statusList)

        return self.__returnCode(status)


    def __returnCode(self, status):
        """
        Creates a return code according to returned statuses.
        Error codes (combination by bitwise or):
            candlepin:      2
            candlepin_auth: 4
            pulp:           8
            pulp_auth:     16
        """
        if status['result'].lower() == 'ok':
            return 0

        code = 0
        # pylint: disable=W0612
        for serviceName, serviceStatus in self.__sortedStatuses(status, reverse=True):
            if serviceStatus['result'] != 'ok':
                code += 1
            code = code << 1
        return code


    def __statusToList(self, status):
        statusList = []
        statusList.append(self.__buildOverallStatusDetail(status))

        for serviceName, serviceStatus in self.__sortedStatuses(status):
            statusList.append(self.__buildServiceStatusDetail(serviceName, serviceStatus))
        return statusList


    @classmethod
    def __sortedStatuses(cls, status, reverse = False):
        for serviceName in sorted(status["status"].keys(), reverse=reverse):
            serviceStatus = status["status"][serviceName]

            yield (serviceName, serviceStatus)

    @classmethod
    def __buildOverallStatusDetail(cls, status):
        return {'status': status["result"]}

    @classmethod
    def __buildServiceStatusDetail(cls, serviceName, serviceStatus):
        detail = serviceStatus
        detail['service'] = serviceName

        if "duration_ms" in detail:
            detail["duration"] = detail["duration_ms"] + "ms"

        return detail
