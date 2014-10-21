/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

/**
 * @ngdoc service
 * @name  Bastion.content-hosts.service:ContentHostsHelper
 *
 * @description
 *   Helper service that contains functionality common amongst content hosts.
 */
angular.module('Bastion.content-hosts').service('ContentHostsHelper',
    function () {

        // The color mapping used here is based upon the mapping utilized by when it displays Host status
        var hostStatusColorMap = {
            'Pending Installation': 'light-blue',
            'Alerts disabled': 'gray',
            'No reports': 'gray',
            'Out of sync': 'orange',
            'Error': 'red',
            'Active': 'light-blue',
            'Pending': 'orange',
            'No Change': 'green'
        };

        this.getStatusColor = function (status) {
            var colors = {
                    'valid': 'green',
                    'partial': 'yellow',
                    'invalid': 'red'
                };

            return colors[status] ? colors[status] : 'red';
        };

        this.getProvisioningStatusColor = function (status) {
            var  color;
            if (status !== undefined) {
                if ((color = hostStatusColorMap[status]) === undefined) {
                    throw "Unknown status = " + status;
                }
            }
            return color;
        };

        this.memory = function (facts) {
            var mem;
            if (facts !== undefined) {
                if (facts.memory !== undefined) {
                    mem = facts.memory["memtotal"];
                }
                if (mem === undefined && facts.dmi !== undefined &&
                   facts.dmi.memory !== undefined) {
                    mem = facts.dmi.memory["size"];
                }
                return memoryInGigabytes(mem);
            } else {
                return "0";
            }
        };

        function memoryInGigabytes(memStr) {
            var mems,
                memory,
                unit;

            if (memStr === undefined || memStr === "") {
                return "0";
            }

            mems = memStr.split(/\s+/);
            memory = parseFloat(mems[0]);
            unit = mems[1];

            switch (unit) {

            case 'B':
                memory = 0;
                break;

            case 'kB':
                memory = 0;
                break;

            case 'MB':
                memory /= 1024;
                break;

            case 'GB':
                break;

            case 'TB':
                memory *= 1024;
                break;

            default:
                // by default memory is in kB
                memory /= (1024 * 1024);
                break;

            }

            memory = Math.round(memory * 100) / 100;
            return memory;
        }

    }
);
